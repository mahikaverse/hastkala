# HastKala

**Empowering India's artisans. Connecting craft to commerce.**

HastKala is a mobile marketplace that connects traditional Indian artisans directly with buyers and bulk B2B buyers — preserving heritage crafts while building sustainable livelihoods.

---

## What is HastKala?

India's artisan communities have carried centuries of craft traditions — block printing from Rajasthan, bamboo work from the Northeast, Banarasi silk weaving, terracotta pottery, and hundreds more. HastKala bridges the gap between these skilled creators and the world that values their work.

- **Artisans** get a digital storefront to showcase their craft, tell their story, and receive orders
- **Buyers** discover authentic handcrafted products from verified artisans across India
- **B2B buyers** source bulk orders directly from artisan clusters with AI-powered matching

---

## Features

### For Artisans
- AI-powered product listing — just speak or snap a photo
- Digital storefront with craft story and product catalog
- Direct orders from buyers with real-time tracking
- Voice-first experience in Hindi and English

### For Buyers
- Browse authentic handcrafted products by craft, region, or material
- Direct checkout with secure payments
- Track orders from artisan to doorstep

### For B2B Buyers
- Post bulk requirements and get AI-matched with the best artisans
- Compare artisan profiles, capacity, and pricing
- Regional artisan discovery — find makers near your city
- End-to-end enquiry and order management

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter (Dart) |
| Backend | FastAPI (Python) |
| Database | Supabase (PostgreSQL) |
| AI | Groq LLM for matching & pricing |
| Auth | Supabase Auth |
| Storage | Supabase Storage |

---

## Project Structure

```
hastkala/
├── mobile/          # Flutter mobile app
│   └── lib/
│       ├── core/        # Models, services, helpers, localization
│       ├── features/    # Screen modules (auth, b2b, catalog, etc.)
│       └── app/         # Router, theme, entry point
├── backend/         # FastAPI backend
│   └── app/
│       ├── api/         # API endpoints
│       └── services/    # Business logic
└── .env             # Environment variables (not committed)
```

---

## Getting Started

### Prerequisites
- Flutter 3.x
- Python 3.11+
- Supabase project (free tier works)

### Mobile App
```bash
cd mobile
flutter pub get
flutter run
```

### Backend
```bash
cd backend
python -m venv .venv
.venv\Scripts\activate      # Windows
source .venv/bin/activate   # macOS/Linux
pip install -r requirements.txt
uvicorn app.main:app --reload
```

---

## Environment Setup

Create a `.env` file in the `backend/` directory:

```
SUPABASE_URL=your_supabase_url
SUPABASE_PUBLISHABLE_KEY=your_publishable_key
SUPABASE_SECRET_KEY=your_secret_key
```

---

## Supported Crafts

Terracotta · Block Printing · Handloom & Silk · Bamboo & Cane · Woodcarving · Metalwork · Lacquerware · Papier-mâché · Leather Craft · Natural Dye Textiles

---

## Our Mission

HastKala exists to ensure that every artisan — regardless of location or technology access — can reach a global audience while preserving the authenticity and soul of Indian handcraft.

**Every product tells a story. Every purchase sustains a tradition.**

---

 
