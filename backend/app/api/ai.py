import base64
import io
import logging
import time

import cv2
import numpy as np
from fastapi import APIRouter, File, HTTPException, UploadFile
from PIL import Image, ImageEnhance, ExifTags
from rembg import remove

logger = logging.getLogger("hastkala.ai")
logging.basicConfig(level=logging.INFO)

router = APIRouter(prefix="/api/ai", tags=["AI"])

ALLOWED_TYPES = {"image/jpeg", "image/png", "image/webp", "image/jpg", "application/octet-stream"}
MAX_SIZE = 15 * 1024 * 1024  # 15MB — phone cameras can produce large files
MAX_PROCESS_DIM = 1500        # Max dimension for rembg processing

_rem_bg_session = None


def get_remove_session():
    global _rem_bg_session
    if _rem_bg_session is None:
        from rembg import new_session
        logger.info("[BG REMOVE] Initializing rembg u2net session...")
        _rem_bg_session = new_session("u2net")
        logger.info("[BG REMOVE] rembg model loaded successfully")
    return _rem_bg_session


def fix_orientation(img: Image.Image) -> Image.Image:
    """Fix EXIF rotation so camera photos are not displayed sideways."""
    try:
        exif = img._getexif()
        if exif is None:
            return img
        orientation_key = None
        for key, val in ExifTags.TAGS.items():
            if val == "Orientation":
                orientation_key = key
                break
        if orientation_key is None:
            return img
        orientation = exif.get(orientation_key)
        if orientation == 3:
            img = img.rotate(180, expand=True)
        elif orientation == 6:
            img = img.rotate(270, expand=True)
        elif orientation == 8:
            img = img.rotate(90, expand=True)
    except Exception:
        pass
    return img


def resize_if_large(img: Image.Image, max_dim: int = MAX_PROCESS_DIM) -> Image.Image:
    """Resize image proportionally if it exceeds max_dim. Preserves aspect ratio."""
    w, h = img.size
    if max(w, h) <= max_dim:
        return img
    ratio = max_dim / max(w, h)
    new_w = int(w * ratio)
    new_h = int(h * ratio)
    logger.info(f"[BG REMOVE] Resized from {w}x{h} to {new_w}x{new_h} for processing")
    return img.resize((new_w, new_h), Image.LANCZOS)


def pil_to_bytes(img: Image.Image, fmt: str = "PNG") -> bytes:
    """Encode a PIL image to bytes."""
    buf = io.BytesIO()
    img.save(buf, format=fmt)
    return buf.getvalue()


def remove_background_from_pil(img: Image.Image) -> Image.Image:
    """
    Run rembg background removal on a PIL Image.
    Returns RGBA PIL Image with background removed.
    Input image is converted to RGB first to normalise format.
    """
    t0 = time.time()
    logger.info("[BG REMOVE] Processing started")
    session = get_remove_session()

    # Normalise to RGB before passing to rembg
    if img.mode not in ("RGB", "RGBA"):
        img = img.convert("RGB")

    # Encode to PNG bytes for rembg (more reliable than JPEG for transparency)
    img_bytes = pil_to_bytes(img, fmt="PNG")
    logger.info(f"[BG REMOVE] Image bytes to rembg: {len(img_bytes)}")

    output_bytes = remove(img_bytes, session=session)
    logger.info(f"[BG REMOVE] Output bytes from rembg: {len(output_bytes)}")

    if not output_bytes:
        raise ValueError("[BG REMOVE ERROR] rembg returned empty output")

    result = Image.open(io.BytesIO(output_bytes)).convert("RGBA")
    logger.info(f"[BG REMOVE] Output mode: {result.mode}, size: {result.size}")
    logger.info(f"[BG REMOVE] Processing completed in {time.time() - t0:.2f}s")
    return result


def place_on_white(fg: Image.Image) -> Image.Image:
    """Composite RGBA image onto a white background, returning RGB."""
    bg = Image.new("RGBA", fg.size, (255, 255, 255, 255))
    bg.paste(fg, mask=fg.split()[3])
    return bg.convert("RGB")


def correct_lighting(img: Image.Image) -> Image.Image:
    enhancer = ImageEnhance.Brightness(img)
    img = enhancer.enhance(1.05)
    enhancer = ImageEnhance.Contrast(img)
    img = enhancer.enhance(1.08)
    enhancer = ImageEnhance.Color(img)
    img = enhancer.enhance(1.02)
    return img


def find_product_bbox(img: Image.Image) -> tuple:
    arr = np.array(img)
    if len(arr.shape) == 3:
        gray = cv2.cvtColor(arr, cv2.COLOR_RGB2GRAY)
    else:
        gray = arr
    _, thresh = cv2.threshold(gray, 240, 255, cv2.THRESH_BINARY_INV)
    contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if not contours:
        return 0, 0, img.width, img.height
    all_points = np.concatenate(contours)
    x, y, w, h = cv2.boundingRect(all_points)
    return x, y, w, h


def smart_crop(img: Image.Image, padding_pct: float = 0.08) -> Image.Image:
    x, y, w, h = find_product_bbox(img)
    pad_x = int(w * padding_pct)
    pad_y = int(h * padding_pct)
    left = max(0, x - pad_x)
    top = max(0, y - pad_y)
    right = min(img.width, x + w + pad_x)
    bottom = min(img.height, y + h + pad_x)
    cropped = img.crop((left, top, right, bottom))
    size = max(cropped.size)
    final = Image.new("RGB", (size, size), (255, 255, 255))
    offset_x = (size - cropped.width) // 2
    offset_y = (size - cropped.height) // 2
    final.paste(cropped, (offset_x, offset_y))
    return final


@router.post("/enhance-image")
async def enhance_image(file: UploadFile = File(...)):
    """
    POST /api/ai/enhance-image
    Accepts a multipart image upload (field name: 'file').
    Returns JSON with:
      - success: bool
      - original_image: data URI of original (JPEG)
      - enhanced_image: data URI of enhanced (JPEG, white bg)
      - transparent_image: data URI of background-removed PNG (RGBA)
      - processing_steps: list of completed steps
    """
    total_start = time.time()
    logger.info("[BG REMOVE] Request received")
    logger.info(f"[BG REMOVE] File: {file.filename!r}, Content-Type: {file.content_type!r}")

    # Accept 'application/octet-stream' as well as standard image MIME types.
    # Some Android camera integrations send the wrong content-type.
    content_type = (file.content_type or "").lower()
    if content_type and content_type not in ALLOWED_TYPES:
        # Try to detect by filename extension before rejecting
        filename = (file.filename or "").lower()
        if not any(filename.endswith(ext) for ext in (".jpg", ".jpeg", ".png", ".webp")):
            logger.error(f"[BG REMOVE ERROR] Invalid file type: {content_type!r}")
            raise HTTPException(
                status_code=400,
                detail=f"Unsupported image type: {content_type}. Use JPEG, PNG or WebP."
            )

    contents = await file.read()
    logger.info(f"[BG REMOVE] Image bytes received: {len(contents)}")

    if len(contents) == 0:
        raise HTTPException(status_code=400, detail="Uploaded file is empty.")

    if len(contents) > MAX_SIZE:
        raise HTTPException(status_code=400, detail="Image too large. Max 15MB.")

    # --- Open & validate image ---
    try:
        img = Image.open(io.BytesIO(contents))
        logger.info(f"[BG REMOVE] Image format: {img.format}, size: {img.size[0]}x{img.size[1]}, mode: {img.mode}")
    except Exception as e:
        logger.error(f"[BG REMOVE ERROR] Cannot open image: {e}")
        raise HTTPException(status_code=400, detail="Invalid or corrupt image file.")

    # --- Fix EXIF orientation & resize large camera photos ---
    img = fix_orientation(img)
    img = resize_if_large(img)

    # Store original bytes for the response (encode from PIL after orientation fix)
    original_buf = io.BytesIO()
    img.convert("RGB").save(original_buf, format="JPEG", quality=88)
    original_b64 = base64.b64encode(original_buf.getvalue()).decode("utf-8")

    steps = []
    bg_removed_rgba: Image.Image | None = None

    # --- Background removal ---
    try:
        bg_removed_rgba = remove_background_from_pil(img)
        steps.append("Background cleaned")
        # Validate output
        if bg_removed_rgba.mode != "RGBA":
            bg_removed_rgba = bg_removed_rgba.convert("RGBA")
        alpha = bg_removed_rgba.split()[3]
        extrema = alpha.getextrema()
        logger.info(f"[BG REMOVE] Alpha channel range: {extrema}")
        if extrema[0] == extrema[1] == 0:
            logger.warning("[BG REMOVE] Warning: alpha channel is all-zero (fully transparent)")
    except Exception as e:
        logger.error(f"[BG REMOVE ERROR] Background removal failed: {e}", exc_info=True)
        # Continue without background removal rather than crashing the whole request
        bg_removed_rgba = None

    # --- Composite onto white for the "enhanced" JPEG ---
    if bg_removed_rgba is not None:
        img_enhanced = place_on_white(bg_removed_rgba)
    else:
        img_enhanced = img.convert("RGB")

    # --- Lighting correction ---
    try:
        img_enhanced = correct_lighting(img_enhanced)
        steps.append("Lighting improved")
        logger.info("[BG REMOVE] Lighting improved")
    except Exception as e:
        logger.error(f"[BG REMOVE ERROR] Lighting correction failed: {e}")

    # --- Smart crop ---
    try:
        img_enhanced = smart_crop(img_enhanced)
        steps.append("E-commerce crop")
        logger.info("[BG REMOVE] E-commerce crop done")
    except Exception as e:
        logger.error(f"[BG REMOVE ERROR] Crop failed: {e}")

    # --- Encode enhanced JPEG (white background) ---
    enhanced_buf = io.BytesIO()
    img_enhanced.save(enhanced_buf, format="JPEG", quality=90)
    enhanced_b64 = base64.b64encode(enhanced_buf.getvalue()).decode("utf-8")
    logger.info(f"[BG REMOVE] Enhanced JPEG bytes: {len(enhanced_buf.getvalue())}")

    # --- Encode transparent PNG (RGBA, actual background removed) ---
    transparent_b64 = None
    if bg_removed_rgba is not None:
        transparent_buf = io.BytesIO()
        bg_removed_rgba.save(transparent_buf, format="PNG")
        transparent_b64 = base64.b64encode(transparent_buf.getvalue()).decode("utf-8")
        logger.info(f"[BG REMOVE] Transparent PNG bytes: {len(transparent_buf.getvalue())}")

    total_time = time.time() - total_start
    logger.info(f"[BG REMOVE] Response sent. Total time: {total_time:.2f}s")

    return {
        "success": True,
        "original_image": f"data:image/jpeg;base64,{original_b64}",
        "enhanced_image": f"data:image/jpeg;base64,{enhanced_b64}",
        "transparent_image": (
            f"data:image/png;base64,{transparent_b64}" if transparent_b64 else None
        ),
        "bg_removed": bg_removed_rgba is not None,
        "processing_steps": steps,
    }


@router.post("/remove-background")
async def remove_background_endpoint(file: UploadFile = File(...)):
    """
    POST /api/ai/remove-background
    Lightweight endpoint: accepts image, returns transparent PNG bytes directly.
    Content-Type of response: image/png
    """
    from fastapi.responses import Response

    logger.info("[BG REMOVE] /remove-background request received")
    logger.info(f"[BG REMOVE] File: {file.filename!r}, Type: {file.content_type!r}")

    contents = await file.read()
    logger.info(f"[BG REMOVE] Image bytes: {len(contents)}")

    if len(contents) == 0:
        raise HTTPException(status_code=400, detail="Uploaded file is empty.")

    try:
        img = Image.open(io.BytesIO(contents))
        logger.info(f"[BG REMOVE] Image format: {img.format}, size: {img.size}, mode: {img.mode}")
    except Exception as e:
        logger.error(f"[BG REMOVE ERROR] Cannot open image: {e}")
        raise HTTPException(status_code=400, detail="Invalid image file.")

    img = fix_orientation(img)
    img = resize_if_large(img)

    try:
        result_rgba = remove_background_from_pil(img)
    except Exception as e:
        logger.error(f"[BG REMOVE ERROR] rembg failed: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Background removal failed: {e}")

    # Validate output
    if result_rgba.mode != "RGBA":
        result_rgba = result_rgba.convert("RGBA")

    out_buf = io.BytesIO()
    result_rgba.save(out_buf, format="PNG")
    output_bytes = out_buf.getvalue()
    logger.info(f"[BG REMOVE] Output PNG bytes: {len(output_bytes)}, mode: {result_rgba.mode}")

    if not output_bytes:
        raise HTTPException(status_code=500, detail="Background removal produced empty output.")

    return Response(content=output_bytes, media_type="image/png")
