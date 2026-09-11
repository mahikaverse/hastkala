import logging
from typing import Optional

from fastapi import APIRouter, File, HTTPException, Query, UploadFile

from app.ai.catalog_extractor import (
    extract_product_details,
    extract_step1_product_details,
    extract_step2_quantity_details,
    extract_step3_story_details,
)
from app.ai.speech_to_text import ALLOWED_AUDIO_TYPES, MAX_AUDIO_SIZE, transcribe_audio

logger = logging.getLogger("hastkala.ai.voice_to_catalog")

router = APIRouter(prefix="/api/ai", tags=["AI"])


@router.post("/voice-to-catalog")
async def voice_to_catalog(
    file: UploadFile = File(...),
    step: Optional[int] = Query(0, description="0=all, 1=product details, 2=quantity, 3=story"),
    language: Optional[str] = Query(None, description="Language hint e.g. hi, en"),
):
    logger.info(
        f"[VoiceCatalog] Request: filename={file.filename!r}, "
        f"content_type={file.content_type!r}, step={step}, language={language}"
    )

    if file.content_type not in ALLOWED_AUDIO_TYPES:
        raise HTTPException(
            status_code=400,
            detail=f"Unsupported audio type: {file.content_type}. Allowed: {', '.join(ALLOWED_AUDIO_TYPES)}",
        )

    contents = await file.read()
    size_kb = len(contents) / 1024
    logger.info(f"[VoiceCatalog] Audio received: {len(contents)} bytes ({size_kb:.1f} KB)")

    if len(contents) > MAX_AUDIO_SIZE:
        raise HTTPException(status_code=400, detail="Audio file too large. Max 25MB.")

    if len(contents) == 0:
        raise HTTPException(status_code=400, detail="Empty audio file received.")

    # ── Step 1: Speech-to-Text ──────────────────────────────────────────────
    stt_result = transcribe_audio(
        contents,
        filename=file.filename or "audio.m4a",
        language=language,
    )

    stt_success = stt_result.get("success", False)
    stt_lang = stt_result.get("language") or "unknown"
    transcript = (stt_result.get("transcript") or "").strip()

    logger.info(
        f"[VoiceCatalog] STT result: success={stt_success}, "
        f"lang={stt_lang}, transcript_len={len(transcript)}"
    )
    if transcript:
        logger.info(f"[VoiceCatalog] Transcript: '{transcript[:150]}'")

    if not stt_success:
        error_msg = stt_result.get("error", "Transcription failed")
        logger.warning(f"[VoiceCatalog] STT failed: {error_msg}")
        return {
            "success": False,
            "language": stt_lang,
            "transcript": "",
            "error": "Speech transcription failed. Please speak clearly and try again.",
            "data": {},
        }

    if not transcript:
        logger.warning("[VoiceCatalog] Empty transcript — no speech detected in audio")
        return {
            "success": False,
            "language": stt_lang,
            "transcript": "",
            "error": "No speech detected in the recording. Please speak clearly and try again.",
            "data": {},
        }

    # ── Step 2: Extraction ──────────────────────────────────────────────────
    try:
        if step == 1:
            logger.info("[VoiceCatalog] Running Step 1 extraction (product details)")
            data_dict = extract_step1_product_details(transcript)
        elif step == 2:
            logger.info("[VoiceCatalog] Running Step 2 extraction (quantity)")
            data_dict = extract_step2_quantity_details(transcript)
        elif step == 3:
            logger.info("[VoiceCatalog] Running Step 3 extraction (story)")
            data_dict = extract_step3_story_details(transcript)
        else:
            logger.info("[VoiceCatalog] Running Full extraction")
            data = extract_product_details(transcript)
            data_dict = data.model_dump()
    except Exception as e:
        logger.error(f"[VoiceCatalog] Extraction failed: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Extraction failed: {e}")

    non_null = [k for k, v in data_dict.items() if v is not None]
    logger.info(f"[VoiceCatalog] Extraction complete. Non-null fields: {non_null}")

    return {
        "success": True,
        "language": stt_lang,
        "transcript": transcript,
        "data": data_dict,
    }
