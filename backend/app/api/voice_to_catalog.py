import logging

from fastapi import APIRouter, File, HTTPException, UploadFile

from app.ai.catalog_extractor import extract_product_details
from app.ai.speech_to_text import ALLOWED_AUDIO_TYPES, MAX_AUDIO_SIZE, transcribe_audio

logger = logging.getLogger("hastkala.ai.voice_to_catalog")

router = APIRouter(prefix="/api/ai", tags=["AI"])


@router.post("/voice-to-catalog")
async def voice_to_catalog(file: UploadFile = File(...)):
    logger.info(f"Voice-to-catalog request: {file.filename}, type={file.content_type}")

    if file.content_type not in ALLOWED_AUDIO_TYPES:
        raise HTTPException(
            status_code=400,
            detail=f"Unsupported audio type: {file.content_type}. Allowed: {', '.join(ALLOWED_AUDIO_TYPES)}",
        )

    contents = await file.read()
    logger.info(f"Audio size: {len(contents) / 1024:.1f} KB")

    if len(contents) > MAX_AUDIO_SIZE:
        raise HTTPException(status_code=400, detail="Audio file too large. Max 25MB.")

    if len(contents) == 0:
        raise HTTPException(status_code=400, detail="Empty audio file.")

    stt_result = transcribe_audio(contents, filename=file.filename or "audio.wav")

    if not stt_result.get("success", False):
        logger.warning(f"Transcription failed: {stt_result.get('error')}. Returning empty transcript for user review.")
        transcript = ""
        language = "unknown"
    else:
        transcript = stt_result.get("transcript", "")
        language = stt_result.get("language") or "unknown"

    if not transcript.strip():
        return {
            "success": True,
            "language": language,
            "transcript": "",
            "data": {
                "product_name": None,
                "category": None,
                "material": None,
                "craft": None,
                "color": None,
                "size": None,
                "weight": None,
                "quantity": None,
                "making_time": None,
                "making_process": None,
                "location": None,
                "price": None,
                "craft_story": None,
            },
        }

    try:
        data = extract_product_details(transcript)
        data_dict = data.model_dump()
    except RuntimeError as e:
        logger.error(f"Extraction failed: {e}")
        raise HTTPException(status_code=503, detail=str(e))

    logger.info(f"Voice-to-catalog complete: lang={language}, transcript_len={len(transcript)}")

    return {
        "success": True,
        "language": language,
        "transcript": transcript,
        "data": data_dict,
    }
