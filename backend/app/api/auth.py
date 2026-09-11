import logging
from typing import Optional

import httpx
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from app.core.config import settings

logger = logging.getLogger("hastkala.auth")
router = APIRouter(prefix="/api/auth", tags=["auth"])


class RegisterRequest(BaseModel):
    name: str
    email: str
    password: str
    role: str = "artisan"  # "artisan", "b2b_seller", "buyer"
    craft: Optional[str] = None
    business_name: Optional[str] = None
    phone: Optional[str] = None


class AutoConfirmRequest(BaseModel):
    user_id: str


@router.post("/register")
def register_user(req: RegisterRequest):
    """
    Registers a new user in Supabase Auth using the admin API.
    Auto-confirms the email so the user can immediately log in without
    hitting email confirmation limits or pending verification states.
    Stores the user role in user_metadata.
    """
    if not settings.SUPABASE_URL or not settings.SUPABASE_SECRET_KEY:
        raise HTTPException(
            status_code=500,
            detail="Supabase is not configured on the backend.",
        )

    # Normalize role
    normalized_role = req.role.lower().strip()
    if normalized_role in ["artisan", "seller"]:
        role_val = "artisan"
    elif normalized_role in ["b2b_seller", "b2bseller", "b2b"]:
        role_val = "b2b_seller"
    else:
        role_val = "buyer"

    url = f"{settings.SUPABASE_URL.rstrip('/')}/auth/v1/admin/users"
    headers = {
        "apikey": settings.SUPABASE_SECRET_KEY,
        "Authorization": f"Bearer {settings.SUPABASE_SECRET_KEY}",
        "Content-Type": "application/json",
    }
    payload = {
        "email": req.email,
        "password": req.password,
        "email_confirm": True,
        "user_metadata": {
            "name": req.name.strip(),
            "role": role_val,
            "craft": req.craft,
            "business_name": req.business_name,
            "phone": req.phone,
        },
    }

    try:
        with httpx.Client(timeout=10.0) as client:
            res = client.post(url, headers=headers, json=payload)
            data = res.json()

            if res.status_code == 200 or res.status_code == 201:
                user_id = data.get("id")
                logger.info(f"Registered new user {req.email} as {role_val} (ID: {user_id})")
                return {
                    "success": True,
                    "user_id": user_id,
                    "email": req.email,
                    "role": role_val,
                    "name": req.name.strip(),
                }
            elif res.status_code == 422 or "already registered" in res.text.lower():
                raise HTTPException(
                    status_code=400,
                    detail="An account with this email already exists. Please login instead.",
                )
            else:
                msg = data.get("msg") or data.get("message") or "Failed to register user"
                logger.error(f"Supabase admin user creation error: {res.status_code} - {res.text}")
                raise HTTPException(status_code=res.status_code, detail=msg)
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error calling Supabase register: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/auto-confirm")
def auto_confirm_user(req: AutoConfirmRequest):
    """
    Confirms an existing user's email via the admin API.
    """
    if not settings.SUPABASE_URL or not settings.SUPABASE_SECRET_KEY:
        raise HTTPException(status_code=500, detail="Supabase not configured.")

    url = f"{settings.SUPABASE_URL.rstrip('/')}/auth/v1/admin/users/{req.user_id}"
    headers = {
        "apikey": settings.SUPABASE_SECRET_KEY,
        "Authorization": f"Bearer {settings.SUPABASE_SECRET_KEY}",
        "Content-Type": "application/json",
    }
    payload = {"email_confirm": True}

    try:
        with httpx.Client(timeout=10.0) as client:
            res = client.put(url, headers=headers, json=payload)
            if res.status_code in [200, 201, 204]:
                return {"success": True}
            raise HTTPException(status_code=res.status_code, detail=res.text)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
