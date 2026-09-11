import logging
import os
import tempfile
from pathlib import Path

from app.core.config import settings

logger = logging.getLogger("hastkala.ai.stt")

_model = None
_MODEL_SIZE = os.getenv("WHISPER_MODEL", "base")
_DEVICE = "cpu"
_COMPUTE_TYPE = "int8"

ALLOWED_AUDIO_TYPES = {
    "audio/mpeg",
    "audio/mp3",
    "audio/wav",
    "audio/x-wav",
    "audio/ogg",
    "audio/flac",
    "audio/webm",
    "audio/mp4",
    "audio/m4a",
    "audio/x-m4a",
}

MAX_AUDIO_SIZE = 25 * 1024 * 1024  # 25MB


def _transcribe_groq(audio_bytes: bytes, filename: str, language: str = None) -> dict:
    import groq

    client = groq.Groq(api_key=settings.GROQ_API_KEY)
    logger.info(f"Transcribing audio via Groq whisper-large-v3-turbo ({len(audio_bytes)} bytes, lang={language})...")

    fname = filename if filename and "." in filename else "audio.m4a"
    kwargs = {
        "file": (fname, audio_bytes),
        "model": "whisper-large-v3-turbo",
        "response_format": "verbose_json",
    }
    if language:
        kwargs["language"] = language

    res = client.audio.transcriptions.create(**kwargs)
    transcript = (res.text or "").strip()
    detected_lang = getattr(res, "language", None) or "unknown"
    logger.info(f"Groq transcription complete: lang={detected_lang}, chars={len(transcript)}")
    return {
        "success": True,
        "language": detected_lang,
        "transcript": transcript,
    }


def _get_local_model():
    global _model
    if _model is None:
        from faster_whisper import WhisperModel
        logger.info(f"Loading local Whisper model '{_MODEL_SIZE}'...")
        _model = WhisperModel(
            _MODEL_SIZE,
            device=_DEVICE,
            compute_type=_COMPUTE_TYPE,
        )
        logger.info("Local Whisper model loaded successfully.")
    return _model


def _transcribe_local(audio_bytes: bytes, filename: str) -> dict:
    model = _get_local_model()
    suffix = Path(filename).suffix or ".wav"
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
        tmp.write(audio_bytes)
        tmp_path = tmp.name

    try:
        segments, info = model.transcribe(
            tmp_path,
            beam_size=1,
            best_of=1,
            language=None,
            vad_filter=True,
        )

        transcript_parts = []
        for segment in segments:
            transcript_parts.append(segment.text.strip())

        transcript = " ".join(transcript_parts).strip()
        language = info.language if info.language else "unknown"

        logger.info(f"Local transcription complete: lang={language}, chars={len(transcript)}")
        return {
            "success": True,
            "language": language,
            "transcript": transcript,
        }
    finally:
        try:
            os.unlink(tmp_path)
        except OSError:
            pass


def transcribe_audio(audio_bytes: bytes, filename: str = "audio.wav", language: str = None) -> dict:
    if settings.GROQ_API_KEY:
        try:
            return _transcribe_groq(audio_bytes, filename, language=language)
        except Exception as e:
            logger.warning(f"Groq transcription failed ({e}). Falling back to local whisper...")

    # 2. Secondary fallback: Local faster-whisper
    try:
        return _transcribe_local(audio_bytes, filename)
    except Exception as e:
        logger.error(f"Local transcription failed: {e}")
        return {
            "success": False,
            "language": None,
            "transcript": "",
            "error": str(e),
        }
