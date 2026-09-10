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

ALLOWED_TYPES = {"image/jpeg", "image/png", "image/webp", "image/jpg"}
MAX_SIZE = 10 * 1024 * 1024  # 10MB

_rem_bg_session = None


def get_remove_session():
    global _rem_bg_session
    if _rem_bg_session is None:
        from rembg import new_session
        _rem_bg_session = new_session("u2net")
        logger.info("rembg model loaded successfully")
    return _rem_bg_session


def fix_orientation(img: Image.Image) -> Image.Image:
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


def resize_if_large(img: Image.Image, max_dim: int = 1500) -> Image.Image:
    w, h = img.size
    if max(w, h) <= max_dim:
        return img
    ratio = max_dim / max(w, h)
    new_w = int(w * ratio)
    new_h = int(h * ratio)
    logger.info(f"Resized from {w}x{h} to {new_w}x{new_h}")
    return img.resize((new_w, new_h), Image.LANCZOS)


def remove_background(img_bytes: bytes) -> Image.Image:
    t0 = time.time()
    session = get_remove_session()
    output = remove(img_bytes, session=session)
    result = Image.open(io.BytesIO(output)).convert("RGBA")
    logger.info(f"Background removed in {time.time() - t0:.2f}s")
    return result


def place_on_background(fg: Image.Image) -> Image.Image:
    bg_color = (255, 255, 255)
    background = Image.new("RGBA", fg.size, bg_color + (255,))
    background.paste(fg, mask=fg.split()[3])
    return background.convert("RGB")


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
    total_start = time.time()
    logger.info(f"=== Enhancement request started ===")
    logger.info(f"File: {file.filename}, Type: {file.content_type}")

    if file.content_type not in ALLOWED_TYPES:
        logger.error(f"Invalid file type: {file.content_type}")
        raise HTTPException(status_code=400, detail="Only JPEG, PNG, WebP images are allowed.")

    contents = await file.read()
    logger.info(f"File size: {len(contents) / 1024:.1f} KB")

    if len(contents) > MAX_SIZE:
        logger.error("File too large")
        raise HTTPException(status_code=400, detail="Image too large. Max 10MB.")

    try:
        img = Image.open(io.BytesIO(contents))
        logger.info(f"Image opened: {img.size[0]}x{img.size[1]}")
    except Exception as e:
        logger.error(f"Failed to open image: {e}")
        raise HTTPException(status_code=400, detail="Invalid image file.")

    img = fix_orientation(img)
    img = resize_if_large(img)

    original_b64 = base64.b64encode(contents).decode("utf-8")
    original_mime = file.content_type

    steps = []

    try:
        t0 = time.time()
        fg = remove_background(contents)
        img = place_on_background(fg)
        steps.append("Background cleaned")
        logger.info(f"Background cleaned in {time.time() - t0:.2f}s")
    except Exception as e:
        logger.error(f"Background removal failed: {e}")

    try:
        t0 = time.time()
        img = correct_lighting(img)
        steps.append("Lighting improved")
        logger.info(f"Lighting improved in {time.time() - t0:.2f}s")
    except Exception as e:
        logger.error(f"Lighting correction failed: {e}")

    try:
        t0 = time.time()
        img = smart_crop(img)
        steps.append("E-commerce crop")
        logger.info(f"E-commerce crop done in {time.time() - t0:.2f}s")
    except Exception as e:
        logger.error(f"Crop failed: {e}")

    buf = io.BytesIO()
    img.save(buf, format="JPEG", quality=90)
    enhanced_b64 = base64.b64encode(buf.getvalue()).decode("utf-8")

    total_time = time.time() - total_start
    logger.info(f"=== Enhancement complete in {total_time:.2f}s ===")

    return {
        "success": True,
        "original_image": f"data:{original_mime};base64,{original_b64}",
        "enhanced_image": f"data:image/jpeg;base64,{enhanced_b64}",
        "processing_steps": steps,
    }
