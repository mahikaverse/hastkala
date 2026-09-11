import base64
import json
import logging
import os
import time
import uuid
from pathlib import Path
from typing import Any, Dict, List, Optional

import httpx
from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, Field

from app.core.config import settings

logger = logging.getLogger("hastkala.api.products")

router = APIRouter(prefix="/api/products", tags=["Products"])

DATA_DIR = Path(__file__).resolve().parent.parent.parent / "data"
PRODUCTS_FILE = DATA_DIR / "products.json"
UPLOADS_DIR = DATA_DIR / "uploads"

# Ensure data directories exist
DATA_DIR.mkdir(parents=True, exist_ok=True)
UPLOADS_DIR.mkdir(parents=True, exist_ok=True)


class ProductCreatePayload(BaseModel):
    id: Optional[str] = None
    name: str
    price: float
    original_price: Optional[float] = None
    category: Optional[str] = "Handcrafted"
    craft: Optional[str] = ""
    material: Optional[str] = ""
    color: Optional[str] = ""
    artisan_name: Optional[str] = "Artisan"
    artisan_id: Optional[str] = "ap_1"
    store_id: Optional[str] = "st_1"
    location: Optional[str] = "India"
    description: Optional[str] = ""
    craft_story: Optional[str] = ""
    making_time: Optional[str] = ""
    tags: Optional[List[str]] = Field(default_factory=list)
    image_base64: Optional[str] = None
    image_url: Optional[str] = None
    stock: Optional[int] = 10
    is_published: Optional[bool] = True


def _load_products() -> List[Dict[str, Any]]:
    if not PRODUCTS_FILE.exists():
        return []
    try:
        with open(PRODUCTS_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
            return data if isinstance(data, list) else []
    except Exception as e:
        logger.error(f"Failed to read products file: {e}")
        return []


def _save_products(products: List[Dict[str, Any]]) -> None:
    try:
        with open(PRODUCTS_FILE, "w", encoding="utf-8") as f:
            json.dump(products, f, indent=2, ensure_ascii=False)
    except Exception as e:
        logger.error(f"Failed to save products file: {e}")


def _upload_to_supabase_storage(filename: str, file_bytes: bytes, content_type: str = "image/jpeg") -> Optional[str]:
    url = settings.SUPABASE_URL
    key = settings.SUPABASE_SECRET_KEY
    if not url or not key:
        return None

    try:
        storage_url = f"{url}/storage/v1/object/products/{filename}"
        headers = {
            "Authorization": f"Bearer {key}",
            "apikey": key,
            "Content-Type": content_type,
            "x-upsert": "true",
        }
        with httpx.Client(timeout=6.0) as client:
            resp = client.post(storage_url, headers=headers, content=file_bytes)
            if resp.status_code in (200, 201):
                public_url = f"{url}/storage/v1/object/public/products/{filename}"
                logger.info(f"Uploaded product image to Supabase Storage: {public_url}")
                return public_url
            else:
                logger.warning(f"Supabase storage upload returned status {resp.status_code}: {resp.text}")
    except Exception as e:
        logger.warning(f"Failed to upload to Supabase Storage: {e}")
    return None


@router.post("", status_code=status.HTTP_201_CREATED)
def create_product(payload: ProductCreatePayload):
    product_id = payload.id or f"prod_{int(time.time())}_{uuid.uuid4().hex[:6]}"
    final_image_url = payload.image_url or ""

    # Process image if provided as base64
    if payload.image_base64 and len(payload.image_base64) > 50:
        try:
            b64_str = payload.image_base64
            if "," in b64_str:
                b64_str = b64_str.split(",", 1)[1]
            image_bytes = base64.b64decode(b64_str)

            # 1. Save local backup file
            image_filename = f"{product_id}.jpg"
            local_path = UPLOADS_DIR / image_filename
            with open(local_path, "wb") as img_file:
                img_file.write(image_bytes)

            # 2. Upload to Supabase Storage for permanent cloud URL
            supabase_url = _upload_to_supabase_storage(image_filename, image_bytes)
            if supabase_url:
                final_image_url = supabase_url
            else:
                # Fallback to local server static URL
                final_image_url = f"/uploads/{image_filename}"
        except Exception as e:
            logger.error(f"Failed to process product image: {e}")

    product_dict = {
        "id": product_id,
        "name": payload.name,
        "price": payload.price,
        "original_price": payload.original_price or payload.price,
        "category": payload.category or "Handcrafted",
        "craft": payload.craft or "",
        "material": payload.material or "",
        "color": payload.color or "",
        "artisan_name": payload.artisan_name or "Artisan",
        "artisan_id": payload.artisan_id or "ap_1",
        "store_id": payload.store_id or "st_1",
        "location": payload.location or "India",
        "description": payload.description or "",
        "craft_story": payload.craft_story or "",
        "making_time": payload.making_time or "",
        "tags": payload.tags or [],
        "image_url": final_image_url,
        "stock": payload.stock or 10,
        "is_published": payload.is_published,
        "created_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    }

    products = _load_products()
    # Replace if existing with same id, else prepend
    idx = next((i for i, p in enumerate(products) if p.get("id") == product_id), -1)
    if idx >= 0:
        products[idx] = product_dict
    else:
        products.insert(0, product_dict)

    _save_products(products)
    logger.info(f"Product '{payload.name}' (id: {product_id}) saved successfully! Image: {final_image_url}")

    return {
        "success": True,
        "message": "Product published and saved successfully!",
        "product": product_dict,
    }


@router.get("")
def list_products(store_id: Optional[str] = None):
    products = _load_products()
    if store_id:
        products = [p for p in products if p.get("store_id") == store_id]
    return {
        "success": True,
        "count": len(products),
        "products": products,
    }


@router.get("/{product_id}")
def get_product(product_id: str):
    products = _load_products()
    for p in products:
        if p.get("id") == product_id:
            return {"success": True, "product": p}
    raise HTTPException(status_code=404, detail="Product not found")
