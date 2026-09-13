import logging
import re
from typing import Optional

import httpx

from app.core.config import settings

logger = logging.getLogger("hastkala.ai.marketing")

MARKETING_PROMPT_EN = """You are a creative marketing copywriter for Indian handcrafted products.
Write a short, attractive marketing message (3-5 sentences max) for this product. Use emojis naturally. Mention price with ₹. End with a call-to-action. Return ONLY the message text.

Product: {product_name}
Description: {description}
Material: {material}
Craft: {craft_type}
Category: {category}
Price: ₹{price}
Artisan: {artisan_name}
Location: {location}
Tags: {tags}"""

TRANSLATE_TO_HI = """You are a professional Hindi translator. Translate the given English marketing message to natural, fluent conversational Hindi (like how a Indian person would casually share on WhatsApp). Use Devanagari script only. Keep emojis in the same positions. Do NOT add any English words in the output. Return ONLY the Hindi translation, nothing else."""

TRANSLATE_TO_EN = """Translate the following Hindi marketing message to natural English. Keep emojis in the same positions. Return ONLY the English translation, nothing else."""


def _has_devanagari(text: str) -> bool:
    for ch in text:
        if '\u0900' <= ch <= '\u097F':
            return True
    return False


def _build_prompt(data: dict) -> str:
    fields = {
        "product_name": data.get("product_name") or "N/A",
        "description": data.get("description") or "N/A",
        "material": data.get("material") or "N/A",
        "craft_type": data.get("craft_type") or "N/A",
        "category": data.get("category") or "N/A",
        "price": data.get("price") or "N/A",
        "tags": ", ".join(data.get("tags") or []) or "N/A",
        "artisan_name": data.get("artisan_name") or "N/A",
        "location": data.get("location") or "N/A",
    }
    return MARKETING_PROMPT_EN.format(**fields)


def _call_llm(system_msg: str, user_msg: str, temperature: float = 0.7, max_tokens: int = 400) -> Optional[str]:
    """Call Groq (primary) then Ollama (fallback)."""
    # Try Groq first
    result = _call_groq(system_msg, user_msg, temperature, max_tokens)
    if result:
        return result
    # Fallback to Ollama
    result = _call_ollama(system_msg, user_msg, temperature, max_tokens)
    if result:
        return result
    return None


def _call_ollama(system_msg: str, user_msg: str, temperature: float = 0.7, max_tokens: int = 400) -> Optional[str]:
    prompt = f"{system_msg}\n\n{user_msg}" if system_msg else user_msg
    try:
        logger.info(f"Marketing: Calling Ollama...")
        with httpx.Client(base_url=settings.OLLAMA_BASE_URL, timeout=httpx.Timeout(30.0, connect=3.0)) as client:
            resp = client.post(
                "/api/generate",
                json={
                    "model": settings.OLLAMA_MODEL,
                    "prompt": prompt,
                    "stream": False,
                    "options": {"temperature": temperature, "num_predict": max_tokens},
                },
            )
            if resp.status_code == 200:
                text = resp.json().get("response", "").strip()
                if text:
                    logger.info("Marketing: Ollama succeeded!")
                    return text
    except Exception as e:
        logger.warning(f"Marketing: Ollama failed: {e}")
    return None


def _call_groq(system_msg: str, user_msg: str, temperature: float = 0.7, max_tokens: int = 400) -> Optional[str]:
    if not settings.GROQ_API_KEY:
        return None
    try:
        import groq

        model_to_use = settings.GROQ_MODEL
        if not model_to_use or model_to_use.startswith("groq/"):
            model_to_use = "qwen/qwen3.8-27b"
        logger.info(f"Marketing: Calling Groq (model={model_to_use})...")
        groq_client = groq.Groq(api_key=settings.GROQ_API_KEY, timeout=15.0)
        messages = []
        if system_msg:
            messages.append({"role": "system", "content": system_msg})
        messages.append({"role": "user", "content": user_msg})
        resp = groq_client.chat.completions.create(
            model=model_to_use,
            messages=messages,
            temperature=temperature,
            max_tokens=max_tokens,
        )
        text = (resp.choices[0].message.content or "").strip()
        if text:
            logger.info("Marketing: Groq succeeded!")
            return text
    except Exception as e:
        logger.warning(f"Marketing: Groq failed: {e}")
    return None


def generate_marketing_message(data: dict, language: str = "en") -> Optional[str]:
    """Two-step: always generate English first, then translate if needed."""
    en_prompt = _build_prompt(data)

    # Step 1: Generate English message
    en_message = _call_llm("", en_prompt, temperature=0.7, max_tokens=400)
    if not en_message:
        return None

    # If English requested, verify it's actually English
    if language != "hi":
        if _has_devanagari(en_message):
            # Model returned Hindi for English request — translate to English
            translated = _call_llm(TRANSLATE_TO_EN, en_message, temperature=0.3, max_tokens=500)
            if translated:
                return translated
        return en_message

    # Step 2: Hindi requested — translate English to Hindi
    hi_message = _call_llm(TRANSLATE_TO_HI, en_message, temperature=0.3, max_tokens=500)
    if hi_message and not _is_english_only(hi_message):
        return hi_message

    return en_message


def _is_english_only(text: str) -> bool:
    """Check if text has no Devanagari at all (pure English)."""
    return not _has_devanagari(text)
