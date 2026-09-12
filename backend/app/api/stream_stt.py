"""WebSocket endpoint for real-time STT via Deepgram Nova-3.

Protocol:
  Client → Server: binary audio chunks (PCM 16-bit 8kHz mono)
  Client → Server: {"type": "CloseStream"} to finish
  Server → Client: {"type":"transcript","text":"...","is_final":bool,"language":"..."}
"""
import asyncio
import json
import logging
import urllib.parse

import websockets
from fastapi import APIRouter, WebSocket, WebSocketDisconnect

from app.core.config import settings

logger = logging.getLogger("hastkala.ai.stream_stt")

router = APIRouter(tags=["AI WebSocket"])

DEEPGRAM_WS_HOST = "wss://api.deepgram.com/v1/listen"

LANGUAGE_MAP = {
    "hi": "hi",
    "hi_IN": "hi",
    "en": "en",
    "en_IN": "en",
    "mr": "mr",
    "mr_IN": "mr",
    "gu": "gu",
    "gu_IN": "gu",
    "bn": "bn",
    "bn_IN": "bn",
    "ta": "ta",
    "ta_IN": "ta",
    "te": "te",
    "te_IN": "te",
}


def _build_deepgram_url(language: str = "hi") -> str:
    dg_lang = LANGUAGE_MAP.get(language, language.split("_")[0] if "_" in language else language)
    params = urllib.parse.urlencode({
        "model": "nova-3",
        "language": dg_lang,
        "detect_language": "false",
        "interim_results": "true",
        "endpointing": "300",
        "utterance_end_ms": "1000",
        "encoding": "linear16",
        "sample_rate": "16000",
        "channels": "1",
    })
    logger.info(f"[LIVE STT] Deepgram WS config: language={dg_lang}, encoding=linear16, sample_rate=16000")
    return f"{DEEPGRAM_WS_HOST}?{params}"


@router.websocket("/ws/stream-stt")
async def stream_stt(websocket: WebSocket):
    await websocket.accept()

    raw_query = websocket.url.query or ""
    params = urllib.parse.parse_qs(raw_query)
    language = params.get("language", ["hi"])[0]

    logger.info(f"[LIVE STT] WebSocket connected (language={language})")

    api_key = settings.DEEPGRAM_API_KEY
    if not api_key:
        logger.error("[LIVE STT ERROR] DEEPGRAM_API_KEY not configured")
        await websocket.send_json({"type": "error", "text": "STT not configured"})
        await websocket.close()
        return

    dg_url = _build_deepgram_url(language)
    logger.info(f"[LIVE STT] Deepgram URL params: language={language}, encoding=linear16, sample_rate=8000")

    try:
        async with websockets.connect(
            dg_url,
            additional_headers={"Authorization": f"Token {api_key}"},
            max_size=2 ** 20,
        ) as dg_ws:
            logger.info("[LIVE STT] Deepgram connected")

            async def _forward_audio():
                chunk_count = 0
                try:
                    while True:
                        msg = await websocket.receive()
                        if msg["type"] == "websocket.receive":
                            if "bytes" in msg and msg["bytes"]:
                                chunk_count += 1
                                if chunk_count % 100 == 1:
                                    logger.info(f"[LIVE STT] Audio chunk #{chunk_count} ({len(msg['bytes'])} bytes)")
                                await dg_ws.send(msg["bytes"])
                            elif "text" in msg:
                                try:
                                    ctrl = json.loads(msg["text"])
                                    if ctrl.get("type") == "CloseStream":
                                        logger.info("[LIVE STT] CloseStream received from client")
                                        await dg_ws.send(json.dumps({"type": "CloseStream"}))
                                        return
                                except (json.JSONDecodeError, TypeError):
                                    pass
                except WebSocketDisconnect:
                    logger.info("[LIVE STT] Client disconnected")
                    try:
                        await dg_ws.send(json.dumps({"type": "CloseStream"}))
                    except Exception:
                        pass

            async def _receive_transcripts():
                try:
                    async for raw in dg_ws:
                        if not isinstance(raw, str):
                            continue
                        data = json.loads(raw)
                        if data.get("type") != "Results":
                            continue
                        ch = data.get("channel", {})
                        alts = ch.get("alternatives", [])
                        if not alts:
                            continue
                        transcript = alts[0].get("transcript", "")
                        is_final = data.get("is_final", False) or data.get("speech_final", False)
                        lang = ch.get("language", data.get("channel", {}).get("language", language))

                        if transcript.strip():
                            if is_final:
                                logger.info(f"[LIVE STT] Final transcript: \"{transcript}\" (lang={lang})")
                            else:
                                logger.debug(f"[LIVE STT] Interim transcript: \"{transcript}\"")

                            await websocket.send_json({
                                "type": "transcript",
                                "text": transcript,
                                "is_final": is_final,
                                "language": lang,
                            })
                except Exception as e:
                    logger.error(f"[LIVE STT ERROR] Receive error: {e}")

            done, pending = await asyncio.wait(
                [
                    asyncio.create_task(_forward_audio()),
                    asyncio.create_task(_receive_transcripts()),
                ],
                return_when=asyncio.FIRST_COMPLETED,
            )
            for t in pending:
                t.cancel()

    except Exception as e:
        logger.error(f"[LIVE STT ERROR] {e}")

    try:
        await websocket.close()
    except Exception:
        pass

    logger.info("[LIVE STT] WebSocket disconnected")
