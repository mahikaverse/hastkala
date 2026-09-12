import logging
from typing import Optional

from fastapi import APIRouter, File, Form, HTTPException, UploadFile

from app.ai.speech_to_text import ALLOWED_AUDIO_TYPES, MAX_AUDIO_SIZE, transcribe_audio

logger = logging.getLogger("hastkala.ai.transcribe")

router = APIRouter(prefix="/api/ai", tags=["AI"])


@router.post("/transcribe")
async def transcribe(file: UploadFile = File(...), language: Optional[str] = Form(None)):
    logger.info(f"Transcribe request: {file.filename}, type={file.content_type}, language={language}")

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

    result = transcribe_audio(contents, filename=file.filename or "audio.wav", language=language)

    if not result["success"]:
        raise HTTPException(status_code=500, detail=f"Transcription failed: {result.get('error', 'Unknown error')}")

    return {
        "success": True,
        "language": result["language"],
        "transcript": result["transcript"],
    }
