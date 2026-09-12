import logging
import os
import tempfile
from pathlib import Path

import httpx

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

# Deepgram content-type mapping for audio file extensions
_DEEPGRAM_MIME = {
    ".mp3": "audio/mpeg",
    ".wav": "audio/wav",
    ".ogg": "audio/ogg",
    ".flac": "audio/flac",
    ".webm": "audio/webm",
    ".mp4": "audio/mp4",
    ".m4a": "audio/mp4",
}


def _guess_mime(filename: str) -> str:
    """Guess MIME type from filename extension."""
    suffix = Path(filename).suffix.lower()
    return _DEEPGRAM_MIME.get(suffix, "audio/mpeg")


# ──────────────────────────────────────────────────────────────────────────────
# PRIMARY: Deepgram Nova-3 STT
# ──────────────────────────────────────────────────────────────────────────────

def _transcribe_deepgram(
    audio_bytes: bytes,
    filename: str,
    language: str = None,
) -> dict:
    """Transcribe audio using Deepgram Nova-3 REST API.

    Deepgram Nova-3 supports 36+ languages natively including Hindi and Hinglish.
    The API auto-detects language when not specified.
    """
    api_key = settings.DEEPGRAM_API_KEY
    if not api_key:
        raise ValueError("DEEPGRAM_API_KEY is not configured")

    mime = _guess_mime(filename)
    logger.info(f"[STT] Deepgram transcription started ({len(audio_bytes)} bytes, mime={mime})")

    params = {
        "model": "nova-3",
        "paragraphs": "true",
        "utt_split": "true",
    }
    if language:
        params["language"] = language
        params["detect_language"] = "false"
        logger.info(f"[STT] Explicit language={language}, detect_language=false")
    else:
        params["language"] = "hi"
        params["detect_language"] = "false"
        logger.info(f"[STT] Default language=hi, detect_language=false")

    logger.info(f"[STT] Deepgram params: {params}, mime={mime}")

    headers = {
        "Authorization": f"Token {api_key}",
        "Content-Type": mime,
    }

    with httpx.Client(timeout=60.0) as client:
        resp = client.post(
            "https://api.deepgram.com/v1/listen",
            params=params,
            headers=headers,
            content=audio_bytes,
        )
        resp.raise_for_status()

    data = resp.json()
    channels = data.get("results", {}).get("channels", [])
    if not channels:
        raise ValueError("Deepgram returned no channels in response")

    alternatives = channels[0].get("alternatives", [])
    if not alternatives:
        raise ValueError("Deepgram returned no alternatives in response")

    transcript = alternatives[0].get("transcript", "").strip()
    detected_lang = data.get("results", {}).get("channels", [{}])[0].get(
        "alternatives", [{}]
    )[0].get("language") or data.get("results", {}).get("language", "unknown")

    # Also try top-level language field
    if detected_lang == "unknown":
        detected_lang = data.get("results", {}).get("language", "unknown")

    confidence = alternatives[0].get("confidence", 0)
    logger.info(f"[STT] Transcript: \"{transcript[:200]}\"")
    logger.info(f"[STT] Transcript length: {len(transcript)} chars")
    logger.info(f"[STT] Detected language: {detected_lang}, confidence: {confidence}")

    return {
        "success": True,
        "language": detected_lang,
        "transcript": transcript,
    }


# ──────────────────────────────────────────────────────────────────────────────
# FALLBACK: Local faster-whisper STT
# ──────────────────────────────────────────────────────────────────────────────

def _get_local_model():
    global _model
    if _model is None:
        from faster_whisper import WhisperModel

        logger.info(f"[STT] Loading local Whisper model '{_MODEL_SIZE}'...")
        _model = WhisperModel(
            _MODEL_SIZE,
            device=_DEVICE,
            compute_type=_COMPUTE_TYPE,
        )
        logger.info("[STT] Local Whisper model loaded successfully.")
    return _model


def _transcribe_local(audio_bytes: bytes, filename: str) -> dict:
    """Fallback STT using local faster-whisper model."""
    logger.info(f"[STT] Falling back to local faster-whisper ({len(audio_bytes)} bytes)")
    model = _get_local_model()
    suffix = Path(filename).suffix or ".wav"
    tmp_path = None

    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
            tmp.write(audio_bytes)
            tmp_path = tmp.name

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

        logger.info(f"[STT] Local transcription complete: lang={language}, chars={len(transcript)}")
        return {
            "success": True,
            "language": language,
            "transcript": transcript,
        }
    finally:
        if tmp_path:
            try:
                os.unlink(tmp_path)
            except OSError:
                pass


# ──────────────────────────────────────────────────────────────────────────────
# MAIN ENTRY POINT — same interface as before
# ──────────────────────────────────────────────────────────────────────────────

def transcribe_audio(
    audio_bytes: bytes,
    filename: str = "audio.wav",
    language: str = None,
) -> dict:
    """Transcribe audio to text.

    Priority:
        1. Deepgram Nova-3 (cloud, fast, accurate)
        2. faster-whisper (local fallback)

    Returns: { success: bool, language: str, transcript: str, error?: str }
    """
    logger.info(f"[STT] Audio received: {len(audio_bytes)} bytes, filename={filename}")

    # 1. PRIMARY: Deepgram Nova-3
    if settings.DEEPGRAM_API_KEY:
        try:
            return _transcribe_deepgram(audio_bytes, filename, language=language)
        except Exception as e:
            logger.warning(f"[STT] Deepgram transcription failed: {e}. Falling back to local whisper...")
    else:
        logger.warning("[STT] DEEPGRAM_API_KEY not configured. Skipping Deepgram.")

    # 2. FALLBACK: Local faster-whisper
    try:
        return _transcribe_local(audio_bytes, filename)
    except Exception as e:
        logger.error(f"[STT] Local transcription also failed: {e}")
        return {
            "success": False,
            "language": None,
            "transcript": "",
            "error": str(e),
        }
