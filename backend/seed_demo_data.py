"""
HastKala demo data seeder (development environment).

- Seeds 18 fictional Indian artisans + 18 stores + 72 handicraft products,
  2 demo buyers, 8 B2B demo orders and 6 saved-artisan links.
- SAFE & REPEATABLE: deterministic UUIDs (uuid5), INSERT-ONLY.
  Existing rows (by id) are skipped. Nothing is ever deleted or overwritten.
- Uses the project's current stack: Supabase service-role client
  (app.core.supabase.get_supabase), existing schema (backend/database/schema.sql)
  and Supabase Auth admin API (best-effort; artisan.user_id stays NULL on failure).
- No real personal information: all people/stories/emails are fictional
  (@hastkala.example reserved demo domain).

Run:
    cd backend
    .venv\\Scripts\\python.exe seed_demo_data.py            # seed + verify
    .venv\\Scripts\\python.exe seed_demo_data.py --dry-run  # show plan only
"""

from __future__ import annotations

import sys
import uuid
from datetime import datetime, timedelta, timezone

def get_client():
    """Return (client, key_label). Prefers service-role key, falls back to publishable key."""
    import os

    try:
        from app.core.config import settings
    except Exception:  # pragma: no cover
        sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
        from app.core.config import settings
    from supabase import create_client

    candidates = [
        ("service-role", getattr(settings, "SUPABASE_SECRET_KEY", "") or ""),
        ("publishable (anon)", getattr(settings, "SUPABASE_PUBLISHABLE_KEY", "") or ""),
    ]
    for label, key in candidates:
        if not key:
            continue
        client = create_client(settings.SUPABASE_URL, key)
        try:
            client.table("artisans").select("id").limit(1).execute()
            return client, label
        except Exception:
            continue
    raise SystemExit("No working Supabase key found in backend/.env")

NS = uuid.UUID("7c9e6679-7425-40de-944b-e07fc1f90ae7")  # fixed namespace -> stable ids
DEMO_PASSWORD = "HastKalaDemo#123"
DRY_RUN = "--dry-run" in sys.argv
REFRESH_IMAGES = "--refresh-images" in sys.argv

NOW = datetime.now(timezone.utc)


def hid(kind: str, key: str) -> str:
    return str(uuid.uuid5(NS, f"hastkala-demo:{kind}:{key}"))


def iso(dt: datetime) -> str:
    return dt.strftime("%Y-%m-%dT%H:%M:%SZ")


def days_ago(n: int) -> str:
    return iso(NOW - timedelta(days=n))


# ============================================================================
# IMAGE POOLS (public URLs already used by backend/database/seed_demo.sql)
# ============================================================================

IMG = {
    "Madhubani Paintings": [
        "https://images.unsplash.com/photo-1493106641515-6b5631de4bb9?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1584589167171-541ce45f1eea?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1544967082-d9d25d867d66?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1601121141461-9d6647bca1ed?w=800&h=800&fit=crop",
    ],
    "Blue Pottery": [
        "https://images.unsplash.com/photo-1610701596007-11502861dcfa?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1590422749897-47036da0b0ff?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1602751584552-8ba73aad10e1?w=800&h=800&fit=crop",
    ],
    "Handloom Textiles": [
        "https://images.unsplash.com/photo-1528459801416-a9e53bbf4e17?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1524292332709-b33366a7f165?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1606760227091-3dd870d97f1d?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1617038220319-276d3cfab638?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1600003014755-ba31aa59c4b6?w=800&h=800&fit=crop",
    ],
    "Embroidery": [
        "https://images.unsplash.com/photo-1591561954557-26941169b49e?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1609139003551-ee40f5f73ec0?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=800&h=800&fit=crop",
    ],
    "Terracotta": [
        "https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1519710164239-da123dc03ef4?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1531835551805-16d864c8d311?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?w=800&h=800&fit=crop",
    ],
    "Wooden Crafts": [
        "https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1608042314453-ae338d80c427?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1620656798579-1984d9e87df7?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1596461404969-9ae70f2830c1?w=800&h=800&fit=crop",
    ],
    "Handmade Jewellery": [
        "https://images.unsplash.com/photo-1620733723572-11c53f73a416?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1594736797933-d0501ba2fe65?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1600166898405-da9535204843?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1615529182904-14819c35db37?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1556228720-195a672e8a03?w=800&h=800&fit=crop",
    ],
    "Bamboo & Cane": [
        "https://images.unsplash.com/photo-1549488344-1f9b8d2bd1f3?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1567696911980-2eed69a46042?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1594040226829-7f251ab46d80?w=800&h=800&fit=crop",
        "https://images.unsplash.com/photo-1526047932273-341f2a7631f9?w=800&h=800&fit=crop",
    ],
}

# Unsplash portraits/craft photos for demo avatars (verified 200 OK).
AVATAR_PHOTOS = [
    "photo-1524292332709-b33366a7f165",
    "photo-1584589167171-541ce45f1eea",
    "photo-1606760227091-3dd870d97f1d",
    "photo-1591561954557-26941169b49e",
    "photo-1609139003551-ee40f5f73ec0",
    "photo-1567538096630-e0c55bd6374c",
    "photo-1519710164239-da123dc03ef4",
    "photo-1608042314453-ae338d80c427",
    "photo-1620656798579-1984d9e87df7",
    "photo-1620733723572-11c53f73a416",
    "photo-1594736797933-d0501ba2fe65",
    "photo-1600166898405-da9535204843",
    "photo-1549488344-1f9b8d2bd1f3",
    "photo-1567696911980-2eed69a46042",
    "photo-1591195853828-11db59a44f6b",
    "photo-1594040226829-7f251ab46d80",
    "photo-1526047932273-341f2a7631f9",
    "photo-1611591437281-460bfbe1220a",
]


def avatar_url(name: str, idx: int = 0) -> str:
    photo = AVATAR_PHOTOS[idx % len(AVATAR_PHOTOS)]
    return f"https://images.unsplash.com/{photo}?w=256&h=256&fit=crop&crop=faces"


# ============================================================================
# 18 FICTIONAL ARTISANS (stories are 150-220 words, entirely invented)
# ============================================================================

ARTISANS = [
    {
        "key": "meera",
        "name": "Meera Devi",
        "craft": "Madhubani Painting",
        "city": "Madhubani",
        "state": "Bihar",
        "years": 18,
        "verified": True,
        "bio": "Master Madhubani artist from Jitwarpur village keeping the Bharni style of Mithila painting alive with natural pigments.",
        "story": (
            "I was born in Jitwarpur, the village that has given India its Madhubani art, into a family where every wall was a canvas. "
            "My grandmother and mother painted for weddings and festivals, and by the age of nine I was filling the gaps in their fish and peacock motifs with a bamboo ekkhi nib. "
            "For years our art decorated only the mud walls of our homes; nobody paid for it. "
            "The turning point came when a craft cooperative taught us how to translate those wall compositions onto handmade paper using dyes we grind ourselves from lampblack, turmeric, kusum flower and indigo. "
            "Each painting takes three to seven days. The Bharni style I practice fills every shape with solid colour, leaving no empty space, because in Mithila we believe emptiness invites sorrow. "
            "The hardest part has been convincing buyers that true Madhubani is never printed and never rushed. "
            "My dream is to open a small studio school in Madhubani town so that my two daughters and their cousins can earn dignified livelihoods from the art our ancestors invented."
        ),
        "store": "Meera Mithila Arts",
        "store_desc": "Authentic hand-painted Madhubani art from Jitwarpur village, Bihar, using natural pigments.",
        "category": "Madhubani Paintings",
        "craft_type": "Madhubani Painting",
        "products": [
            ("Madhubani Fish Pond Painting", "Hand-painted Bharni style Madhubani painting on handmade paper. Fish symbolise fertility and good fortune in Mithila tradition. Natural dyes only, signed by the artist.", 2400, 2999, 12, "Wall Art", "Handmade Paper", "250g", "45cm x 35cm", ["Madhubani", "Bharni", "Wall Art", "Bihar", "Handmade", "Natural Dye"], True),
            ("Madhubani Krishna Leela Painting", "Detailed Madhubani painting of Krishna's childhood leelas, outlined with a bamboo nib and filled with vibrant natural colours. Takes five days to complete.", 3200, 3800, 8, "Wall Art", "Handmade Paper", "300g", "50cm x 40cm", ["Madhubani", "Krishna", "Religious", "Wall Art", "Bihar"], False),
            ("Madhubani Tree of Life Painting", "Classic Madhubani Tree of Life composition with birds, serpents and lotus motifs woven into the branches. Painted entirely freehand without sketches.", 1800, 2200, 15, "Wall Art", "Handmade Paper", "200g", "40cm x 30cm", ["Madhubani", "Tree of Life", "Wall Art", "Gift"], False),
            ("Madhubani Wedding Blessing Painting", "Traditional Kohbar ghat Madhubani painting made for wedding chambers, featuring lotus, bamboo and parrots as symbols of marital bliss. Premium commission piece.", 4500, 5200, 6, "Wall Art", "Handmade Paper", "400g", "60cm x 45cm", ["Madhubani", "Kohbar", "Wedding", "Premium", "Bihar"], False),
        ],
    },
    {
        "key": "sunita",
        "name": "Sunita Jha",
        "craft": "Madhubani Painting",
        "city": "Darbhanga",
        "state": "Bihar",
        "years": 12,
        "verified": True,
        "bio": "Godhna-style Madhubani artist from Darbhanga known for fine line work and mythological narratives on handmade paper and canvas.",
        "story": (
            "Darbhanga is called the cultural heart of Mithila, and I grew up listening to my aunts sing while their needles and brushes moved together. "
            "Unlike the bold Bharni fills of my cousin Meera, I fell in love with Godhna, the line-drawing style where the whole story is told through delicate strokes and hatching. "
            "I trained under a government craft master for two years after school, learning how to prepare paper with wheat starch and how to cut my own bamboo pens. "
            "For a long time I struggled because Godhna work is slow and buyers wanted quick, colourful pieces. Galleries in Delhi began to understand it only in the last few years, and now those fine-line paintings fetch better prices than the filled ones. "
            "I have trained fourteen women in my neighbourhood so that festival orders can be shared instead of turning us into a factory. "
            "Challenges remain: cheap printed Madhubani from outside Bihar still confuses customers, so I sign and photograph every stage of my work. "
            "I aspire to hold a solo exhibition of Godhna narratives from the Ramayana, painted the way my grandmother told them to me."
        ),
        "store": "Sunita Mithila Studio",
        "store_desc": "Fine Godhna-line Madhubani paintings from Darbhanga, Bihar, hand-drawn with bamboo nibs.",
        "category": "Madhubani Paintings",
        "craft_type": "Madhubani Painting",
        "products": [
            ("Madhubani Godhna Style Painting", "Pure line-work Godhna Madhubani on handmade paper. Entire composition built from fine strokes and hatching, no colour fills. Takes four days.", 2100, 2500, 10, "Wall Art", "Handmade Paper", "200g", "40cm x 30cm", ["Madhubani", "Godhna", "Line Art", "Bihar", "Wall Art"], True),
            ("Madhubani Bharni Peacock Painting", "Vivid Bharni style peacock Madhubani with rich natural dyes. The peacock is Mithila's symbol of beauty and monsoon joy.", 2800, 3300, 9, "Wall Art", "Handmade Paper", "250g", "45cm x 35cm", ["Madhubani", "Peacock", "Bharni", "Wall Art"], False),
            ("Madhubani Dussehra Scene Painting", "Narrative Madhubani panel depicting Ravana's ten heads and the victory of good over evil, painted for the Darbhanga Dussehra fair series.", 3600, 4200, 5, "Wall Art", "Handmade Paper", "350g", "55cm x 40cm", ["Madhubani", "Dussehra", "Narrative", "Festival"], False),
            ("Madhubani Lotus Pond Mini Painting", "Compact Madhubani lotus pond composition, ideal for gifting and small walls. Handmade paper with natural dyes and artist signature.", 1200, 1500, 20, "Wall Art", "Handmade Paper", "120g", "25cm x 20cm", ["Madhubani", "Lotus", "Mini", "Gift", "Affordable"], False),
        ],
    },
    {
        "key": "ramesh",
        "name": "Ramesh Kumar",
        "craft": "Blue Pottery",
        "city": "Jaipur",
        "state": "Rajasthan",
        "years": 25,
        "verified": True,
        "bio": "Fifth-generation master potter from Jaipur and award winner for reviving quartz-based blue pottery with traditional cobalt and turquoise glazes.",
        "story": (
            "Blue pottery is an alchemy of quartz stone powder, fuller's earth and gum; it contains no clay at all, which is why it is so fragile and so magical. "
            "My grandfather was among the few artisans who revived Jaipur blue pottery after it nearly disappeared, and I grew up grinding quartz on a stone slab behind his workshop near Sanganer. "
            "I sit barefoot at the traditional wheel because the toe gives the finest control over the thin quartz dough. "
            "Each vase, plate and bowl is hand-painted with cobalt oxide and copper oxide, then fired slowly for nearly three days in a wood kiln. "
            "The hardest lesson was learning to accept breakage: even today almost one piece in five cracks in the kiln, and that loss is part of the craft. "
            "Government craft awards and orders from emporiums have given my workshop stability, but my real worry is that very few young people want to learn a craft where failure is so common. "
            "I run a free evening class for eight apprentices and hope that one of them will carry the cobalt brush into the next generation."
        ),
        "store": "Ramesh Blue Pottery",
        "store_desc": "Traditional Jaipur blue pottery using quartz powder, cobalt oxide and turquoise glazes.",
        "category": "Blue Pottery",
        "craft_type": "Blue Pottery",
        "products": [
            ("Cobalt Blue Pottery Flower Vase", "Hand-painted cobalt blue flower vase in traditional Jaipur blue pottery style. Made from quartz powder and hand-painted with cobalt oxide, fired at 800 degrees Celsius.", 1850, 2200, 15, "Vases", "Quartz Powder", "1.2kg", "25cm x 15cm", ["Blue Pottery", "Vase", "Jaipur", "Handpainted", "Cobalt Blue"], True),
            ("Blue Pottery Dinner Plate Set (4 pcs)", "Set of 4 hand-painted blue pottery dinner plates with unique floral motifs and food-safe glaze. The quartz base makes them surprisingly lightweight.", 3500, 4000, 10, "Dinnerware", "Quartz Powder", "3.5kg", "27cm diameter each", ["Blue Pottery", "Dinner Plate", "Set of 4", "Jaipur"], False),
            ("Blue Pottery Decorative Tile Set (6)", "Hand-painted decorative wall tiles in classic blue and white, perfect for a kitchen backsplash or wall art. Each tile carries a different traditional Jaipur motif.", 1200, None, 25, "Tiles", "Quartz Powder", "2kg", "15cm x 15cm each", ["Blue Pottery", "Wall Tile", "Set of 6", "Kitchen", "Handpainted"], False),
            ("Blue Pottery Jewellery Box", "Exquisite hand-painted blue pottery jewellery box with hinged lid and traditional peacock motif in cobalt blue. Beautiful gifting piece.", 950, 1100, 20, "Accessories", "Quartz Powder", "600g", "15cm x 10cm x 8cm", ["Blue Pottery", "Jewellery Box", "Gift", "Peacock Motif"], False),
        ],
    },
    {
        "key": "pooja",
        "name": "Pooja Mehra",
        "craft": "Blue Pottery",
        "city": "Jaipur",
        "state": "Rajasthan",
        "years": 14,
        "verified": True,
        "bio": "Contemporary blue pottery artisan from Jaipur blending turquoise glazes with modern tableware forms for everyday Indian homes.",
        "story": (
            "I came to blue pottery almost by accident, joining a women's craft self-help group in Jaipur at twenty-one while looking for work after my marriage. "
            "The turquoise glaze stole my heart immediately. Where my colleagues preferred classic cobalt, I started experimenting with copper oxide ratios until I found that soft sea-green that has become my signature. "
            "Over fourteen years I have moved beyond the traditional vase shapes; my tableware is designed for modern kitchens: stackable cups, serving bowls that go from oven to table, plates that fit standard dining sets. "
            "The quartz dough is still prepared by hand and every piece is still fired in a wood kiln, so the traditional heart remains. "
            "The biggest challenge for women in our craft has been the physical kiln work and the long hours away from home; I solved it by building a second kiln at the workshop and scheduling firing days collectively. "
            "My workshop now employs nine women. My aspiration is to take Jaipur blue pottery onto national design store shelves without losing a single hand-painted stroke."
        ),
        "store": "Pooja Turquoise Studio",
        "store_desc": "Modern turquoise-glazed blue pottery tableware from Jaipur, hand-painted and kiln fired.",
        "category": "Blue Pottery",
        "craft_type": "Blue Pottery",
        "products": [
            ("Blue Pottery Wall Plate Set (3)", "Set of three hand-painted blue pottery wall plates with turquoise centre motifs and cobalt borders. Ready to hang with installed hooks.", 2600, 3100, 12, "Wall Decor", "Quartz Powder", "1.8kg", "20cm diameter each", ["Blue Pottery", "Wall Plate", "Set of 3", "Turquoise", "Jaipur"], True),
            ("Blue Pottery Tea Cups Set (6)", "Set of six lightweight blue pottery tea cups with food-safe glaze and floral hand-painting. Each cup holds 150ml and is dishwasher-safe on gentle cycle.", 2999, 3600, 14, "Dinnerware", "Quartz Powder", "1.5kg", "8cm height, 7cm diameter", ["Blue Pottery", "Tea Cups", "Set of 6", "Tableware"], False),
            ("Blue Pottery Oil Burner Lamp", "Hand-painted blue pottery aroma oil burner with traditional jaal pattern. Place a tealight below the bowl for a warm evening glow.", 850, 999, 30, "Home Fragrance", "Quartz Powder", "400g", "10cm x 10cm x 8cm", ["Blue Pottery", "Oil Burner", "Home Decor", "Gift"], False),
            ("Blue Pottery Serving Bowl", "Large hand-painted blue pottery serving bowl with turquoise interior glaze. Perfect for salads, fruits or as a centrepiece.", 1450, 1750, 18, "Dinnerware", "Quartz Powder", "900g", "22cm diameter x 10cm height", ["Blue Pottery", "Serving Bowl", "Tableware", "Turquoise"], False),
        ],
    },
    {
        "key": "kavita",
        "name": "Kavita Sharma",
        "craft": "Handloom & Banarasi Silk",
        "city": "Varanasi",
        "state": "Uttar Pradesh",
        "years": 22,
        "verified": True,
        "bio": "Master handloom weaver from Madanpura, Varanasi, specialising in authentic pure silk Banarasi sarees and heritage zari motifs.",
        "story": (
            "In the narrow lanes of Madanpura in Varanasi, the rhythmic clack of pit looms has been the soundtrack of my entire life. "
            "My father sat at the loom before sunrise and I grew up sorting pure mulberry silk threads and untangling gold zari spools. "
            "A single bridal Banarasi saree can take up to forty days of painstaking hand weaving, with the kadwa technique where every motif is woven separately and then joined. "
            "When a bride wears our saree, she is wearing decades of our family's prayers. "
            "The hardest years were when powerloom copies flooded the market at a fraction of our price and buyers could not tell the difference. "
            "We fought back with government handloom certification, a mark in the border of every genuine piece we weave. "
            "My two sons now sit at the looms beside me and have started photographing each saree for online sale, which has brought us direct city customers without middlemen. "
            "My aspiration is to revive three almost-lost mughal motifs that exist only in our family's old design notebooks."
        ),
        "store": "Kavita Handloom",
        "store_desc": "Authentic Banarasi silk handloom from Varanasi with real zari work and handloom certification.",
        "category": "Handloom Textiles",
        "craft_type": "Handloom & Silk",
        "products": [
            ("Banarasi Silk Dupatta with Real Zari", "Pure Banarasi silk dupatta with real silver zari dipped in gold. Intricate jaal pattern woven on a traditional pit loom over fifteen days. A true heirloom piece.", 8500, 9500, 8, "Dupatta", "Pure Silk", "250g", "250cm x 90cm", ["Banarasi Silk", "Zari", "Handloom", "Dupatta", "Varanasi"], True),
            ("Banarasi Silk Stole", "Lightweight Banarasi silk stole with a delicate temple border pattern. Soft texture with rich sheen, ideal for office wear and gifting.", 3200, None, 12, "Stole", "Silk Blend", "150g", "200cm x 60cm", ["Banarasi Silk", "Stole", "Handloom", "Temple Border"], False),
            ("Handwoven Cotton Silk Saree", "Beautiful cotton-silk blend saree with traditional Varanasi buti pattern. Lightweight and comfortable for all-day wear, comes with matching blouse piece.", 4500, 5200, 10, "Saree", "Cotton Silk Blend", "400g", "550cm x 120cm", ["Saree", "Handloom", "Cotton Silk", "Buti Pattern"], False),
            ("Banarasi Silk Cushion Cover Set", "Set of two Banarasi silk cushion covers with woven zari buti motifs. Hidden zip closure and soft cotton backing.", 1900, 2300, 22, "Cushion Covers", "Silk Blend", "300g", "45cm x 45cm (set of 2)", ["Banarasi", "Cushion Cover", "Home Decor", "Zari"], False),
        ],
    },
    {
        "key": "balwant",
        "name": "Balwant Singh",
        "craft": "Phulkari Handloom",
        "city": "Patiala",
        "state": "Punjab",
        "years": 20,
        "verified": True,
        "bio": "Phulkari weaver from Patiala whose family has woven the famous bagh dupattas of Punjab on khaddar ground for six generations.",
        "story": (
            "Phulkari means 'flower work', and in our Patiala household the women have embroidered phulkari while the men prepared the khaddar base cloth on the handloom. "
            "I learned both. The bagh, where the whole field is covered so densely with floss silk that the base cloth disappears, was traditionally made by grandmothers for a granddaughter's wedding. "
            "One bagh can take a woman a full year of evening work. "
            "I lost my father to a heart attack when I was twenty-two and had to take over the loom with three younger sisters at home. "
            "The craft nearly died in the nineties when Punjabi families stopped buying handmade dhanak and bought mill dupattas instead. "
            "A revival project by the state handicraft board in the early 2000s brought work back, and today our phulkari reaches export buyers as well. "
            "The challenge now is honest pricing: a genuine bagh needs months, and customers often compare it with powerloom imitations. "
            "I aspire to register a phulkari geographical indication mark for Patiala so our stitch is protected the way Banaras silk is."
        ),
        "store": "Balwant Phulkari House",
        "store_desc": "Traditional Punjabi phulkari and bagh embroidery on hand-loomed khaddar from Patiala.",
        "category": "Handloom Textiles",
        "craft_type": "Phulkari Weave",
        "products": [
            ("Phulkari Embroidered Dupatta", "Vibrant phulkari dupatta embroidered with floss silk in geometric chukkis on hand-loomed khaddar ground. Woven base, hand-embroidered surface.", 2600, 3100, 14, "Dupatta", "Khaddar Cotton with Silk Thread", "250g", "230cm x 85cm", ["Phulkari", "Punjab", "Dupatta", "Handloom", "Embroidery"], True),
            ("Phulkari Bagh Handwoven Shawl", "Dense bagh shawl where floss silk covers the entire khaddar field. Traditional wedding-piece technique, takes forty days to complete.", 4800, 5600, 7, "Shawl", "Khaddar Cotton with Silk Thread", "500g", "250cm x 100cm", ["Phulkari", "Bagh", "Shawl", "Wedding", "Premium"], False),
            ("Phulkari Cushion Cover Set of 2", "Set of two phulkari cushion covers with classic diamond chukki patterns. Khaddar front, cotton back with zip.", 1400, 1700, 25, "Cushion Covers", "Khaddar Cotton", "300g", "45cm x 45cm (set of 2)", ["Phulkari", "Cushion Cover", "Home Decor", "Punjab"], False),
            ("Phulkari Table Runner", "Hand-embroidered phulkari table runner with floral vine border on khaddar ground. Brightens everyday dining tables.", 950, 1200, 30, "Table Runner", "Khaddar Cotton", "180g", "150cm x 40cm", ["Phulkari", "Table Runner", "Home Decor", "Affordable"], False),
        ],
    },
    {
        "key": "lakshmi",
        "name": "Lakshmi Yadav",
        "craft": "Chikankari Embroidery",
        "city": "Lucknow",
        "state": "Uttar Pradesh",
        "years": 16,
        "verified": True,
        "bio": "Chikankari master embroiderer from Lucknow's old city, expert in shadow work, jaali and murri stitches passed down through five generations.",
        "story": (
            "Chikankari came to Lucknow with the Mughal courts, and our family has practised it in Chowk for five generations. "
            "My grandmother could execute thirty-two stitches; I know twenty-four of them well and teach all of them. "
            "The finest is jaali, where the fabric is drawn apart thread by thread to create a lattice without cutting, and shadow work, where the floss sits behind sheer muslin so the design glows softly from the front. "
            "We still use white-on-white mulmul for the classic look, and natural colours for contemporary pieces. "
            "Life changed for the better when designer labels began sourcing directly from karigars like us instead of through contractors. "
            "The struggle remains the long, hard-to-see needlework: many of us need spectacles by forty, and payment cycles from big exporters can stretch months. "
            "I have a group of nineteen women who work from their homes and we insist on weekly payment. "
            "My dream is a small Chikankari museum in Chowk showing every stitch and its history, so tourists understand what they are buying."
        ),
        "store": "Lakshmi Chikan Ghar",
        "store_desc": "Hand-embroidered Chikankari from Lucknow's Chowk, featuring classic jaali and shadow work.",
        "category": "Embroidery",
        "craft_type": "Chikankari Embroidery",
        "products": [
            ("Chikankari Cotton Kurti", "Hand-embroidered Chikankari kurti in soft cotton mulmul with jaali and murri stitches. Straight cut with side slits, comes unstitched at sleeves for tailoring.", 2400, 2900, 16, "Kurti", "Cotton Mulmul", "300g", "Size M-L (regular fit)", ["Chikankari", "Kurti", "Lucknow", "Handmade", "Cotton"], True),
            ("Chikankari Embroidered Dupatta", "Sheer cotton dupatta with all-over Chikankari shadow work in white thread. Lightweight with scalloped edges.", 1800, 2200, 20, "Dupatta", "Cotton Chanderi", "150g", "230cm x 80cm", ["Chikankari", "Dupatta", "Shadow Work", "Lucknow"], False),
            ("Chikankari Cushion Cover Set", "Set of two cotton cushion covers with hand Chikankari jaali work. Hidden zip, cotton reverse.", 1300, 1600, 24, "Cushion Covers", "Cotton", "280g", "40cm x 40cm (set of 2)", ["Chikankari", "Cushion Cover", "Home Decor", "Jaali"], False),
            ("Chikankari Table Linen Set", "Hand-embroidered table runner with two napkins, Chikankari floral buti work on cotton. Gift-boxed.", 2100, 2500, 12, "Table Linen", "Cotton", "350g", "Runner 140cm x 35cm", ["Chikankari", "Table Linen", "Gift", "Home Decor"], False),
        ],
    },
    {
        "key": "fatima",
        "name": "Fatima Begum",
        "craft": "Zardozi Embroidery",
        "city": "Bhopal",
        "state": "Madhya Pradesh",
        "years": 24,
        "verified": True,
        "bio": "Zardozi embroidery artist from Bhopal continuing the city's royal court-craft tradition with metallic dori, sequins and dabka wire.",
        "story": (
            "Zardozi, literally 'gold embroidery', was the court craft of Bhopal's nawabs, and my family were among the karigars who embroidered their sherwanis and pashminas. "
            "I learned the aari hook from my uncle when I was twelve, sitting on a wooden adda frame that still stands in our workshop today. "
            "The craft uses dori, dabka, sequins and kora wire, all metallic, worked into velvet, silk or georgette. "
            "A single zardozi clutch can take three days; a bridal wall hanging can take three months. "
            "When royal patronage ended after independence, many zardozi families left the craft. Ours survived because my mother started making small purses for local shops. "
            "Today Bollywood costume designers and export houses bring us back to life, but hand zardozi is increasingly replaced by machine imitation that sells for a tenth of the price. "
            "We now train apprentices and stamp every piece with our workshop mark. "
            "I hope to open a Zardozi centre of excellence in Bhopal where the old court stitches are documented stitch by stitch for future generations."
        ),
        "store": "Fatima Zardozi Works",
        "store_desc": "Hand zardozi metallic embroidery from Bhopal using traditional aari, dabka and dori work.",
        "category": "Embroidery",
        "craft_type": "Zardozi Embroidery",
        "products": [
            ("Zardozi Embroidered Clutch", "Hand zardozi embroidered clutch on raw silk with dabka, dori and sequin work. Magnetic closure with satin lining. Three days of aari work.", 3200, 3800, 12, "Clutch", "Raw Silk with Metallic Thread", "250g", "22cm x 12cm", ["Zardozi", "Clutch", "Handmade", "Bhopal", "Party Wear"], True),
            ("Zardozi Wall Hanging", "Regal zardozi wall hanging on velvet depicting a Mughal garden panel with metallic dori and sequins. Takes three months to complete.", 4500, 5200, 6, "Wall Decor", "Velvet with Metallic Thread", "600g", "60cm x 45cm", ["Zardozi", "Wall Hanging", "Velvet", "Premium", "Mughal"], False),
            ("Zardozi Potli Bag", "Drawstring potli bag embroidered with zardozi florals on silk. Traditional festive accessory with pearl-tipped drawstrings.", 2600, 3100, 15, "Potli Bag", "Silk with Metallic Thread", "200g", "18cm x 18cm", ["Zardozi", "Potli", "Festive", "Gift"], False),
            ("Zardozi Cushion Cover", "Single cushion cover with heavy zardozi border embroidery on dupion silk. Zip closure, cotton reverse.", 1800, 2100, 18, "Cushion Covers", "Dupion Silk", "320g", "45cm x 45cm", ["Zardozi", "Cushion Cover", "Home Decor", "Silk"], False),
        ],
    },
    {
        "key": "rukmini",
        "name": "Rukmini Pal",
        "craft": "Terracotta",
        "city": "Krishnanagar",
        "state": "West Bengal",
        "years": 14,
        "verified": True,
        "bio": "Terracotta sculptor from Krishnanagar continuing Bengal's famous clay figure tradition with festival horses, deities and household forms.",
        "story": (
            "Krishnanagar has been famous for clay dolls since the eighteenth century, when the local maharaja encouraged potters to model figures of Europeans, saints and gods. "
            "I am the first woman in my family to sit at the potter's wheel; my father at first refused to teach me. "
            "I persisted, learned from a neighbour, and now run my own kiln. "
            "The clay of the Churni river is fine and grey, and we prepare it by trampling and sieving before modelling. "
            "Horses with elaborate bridles, the Bankura style that has become Bengal's emblem, are my specialty; they are coil-built, not moulded, so no two are identical. "
            "After sun-drying for a week, the pieces are fired in a covered kiln with rice husk at low temperature, which gives terracotta its warm orange glow. "
            "The monsoon is hard: rain stops drying for weeks and festival orders pile up in autumn. "
            "I have trained fifteen women of my village and aspire to supply terracotta garden sculpture to landscape projects across India."
        ),
        "store": "Rukmini's Clay World",
        "store_desc": "Krishnanagar terracotta sculptures and household pieces, coil-built and rice-husk fired.",
        "category": "Terracotta",
        "craft_type": "Terracotta",
        "products": [
            ("Terracotta Horse Showpiece Pair", "Pair of traditional Bengal terracotta horses with elaborate bridles, coil-built and hand-finished. Classic Bankura form from Krishnanagar clay.", 2400, 2900, 12, "Showpiece", "River Clay", "2.2kg", "30cm height each", ["Terracotta", "Horse", "Bengal", "Showpiece", "Handmade"], True),
            ("Terracotta Table Vase", "Simple wheel-thrown terracotta vase with burnt-orange finish, sealed for water use. Minimal form celebrating Churni river clay.", 1200, 1500, 20, "Vases", "River Clay", "900g", "20cm height x 12cm diameter", ["Terracotta", "Vase", "Minimal", "Table Decor"], False),
            ("Terracotta Flower Pot Set (3)", "Set of three hand-thrown terracotta flower pots in graduated sizes with drainage saucers. Unglazed natural finish.", 1600, 1900, 25, "Garden", "River Clay", "3kg", "10cm, 15cm, 20cm diameter", ["Terracotta", "Flower Pot", "Garden", "Set of 3"], False),
            ("Terracotta Ganesh Idol", "Hand-modelled terracotta Lord Ganesh idol with traditional Bengali features. Eco-friendly, dissolves harmlessly in water after worship.", 900, 1100, 30, "Idols", "River Clay", "700g", "15cm height", ["Terracotta", "Ganesh", "Eco Friendly", "Religious"], False),
        ],
    },
    {
        "key": "sandeep",
        "name": "Sandeep Kumar",
        "craft": "Terracotta",
        "city": "Bankura",
        "state": "West Bengal",
        "years": 11,
        "verified": True,
        "bio": "Bankura terracotta artisan from Panchmura crafting the iconic horses, Chhau masks and ritual forms of western Bengal.",
        "story": (
            "Panchmura, my village in Bankura, has produced terracotta horses for centuries; our district's horse even sits on India's national craft emblem. "
            "I belong to the potters' community and grew up watching my father coil-build the long-necked bankura horse that collectors worldwide recognise. "
            "Each horse is assembled from separately rolled coils, the joints smoothed with wet fingers, the bridles and crests added last. "
            "We dig our clay from the village tank, age it for months, and fire in a dome kiln fuelled with straw and husk. "
            "In recent years orders have grown thanks to online marketplaces, but the craft faces real challenges: good clay is becoming scarce as ponds are filled for construction, and younger men leave for city jobs because terracotta income is seasonal. "
            "I have experimented with terracotta Chhau masks and tea-light holders to create work for non-festival months, and those pieces now sell as well as the horses. "
            "My aspiration is a village-level kiln cooperative that shares firing costs and keeps five families working through the monsoon."
        ),
        "store": "Sandeep Bankura Clay",
        "store_desc": "Authentic Bankura terracotta from Panchmura: horses, Chhau masks and ritual clay forms.",
        "category": "Terracotta",
        "craft_type": "Terracotta",
        "products": [
            ("Bankura Terracotta Horse Large", "Large iconic Bankura horse with traditional long neck and bridle, coil-built in Panchmura clay and rice-husk fired. Emblem of Indian terracotta craft.", 3600, 4200, 8, "Showpiece", "Panchmura Clay", "4.5kg", "45cm height", ["Bankura", "Terracotta", "Horse", "Bengal", "Iconic"], True),
            ("Terracotta Chhau Mask", "Hand-modelled terracotta mask of a Chhau dance character with hand-painted features. Wall-mountable collector piece.", 1500, 1800, 14, "Masks", "Panchmura Clay", "800g", "25cm x 20cm", ["Terracotta", "Chhau", "Mask", "Bengal", "Wall Decor"], False),
            ("Terracotta Tea Light Holder Set", "Set of four perforated terracotta tea-light holders casting floral shadow patterns. Monsoon-safe clay fired at stable temperature.", 850, 1000, 35, "Home Decor", "Panchmura Clay", "600g", "8cm height each", ["Terracotta", "Tea Light", "Set of 4", "Home Decor", "Affordable"], False),
            ("Terracotta Wind Chime", "Terracotta wind chime with hand-strung clay beads and a central bell form. Soothing monsoon-porch sound, natural clay finish.", 700, 900, 40, "Garden", "Panchmura Clay", "400g", "40cm length", ["Terracotta", "Wind Chime", "Garden", "Gift"], False),
        ],
    },
    {
        "key": "sitanair",
        "name": "Sita Nair",
        "craft": "Woodcarving",
        "city": "Thrissur",
        "state": "Kerala",
        "years": 20,
        "verified": True,
        "bio": "Traditional woodcarver from Thrissur shaping rosewood, teak and sandalwood into temple-style sculptures and heritage boxes using only chisel and mallet.",
        "story": (
            "Woodcarving has been our family's worship for generations in Thrissur. "
            "Working with fragrant sandalwood, seasoned rosewood and teak, my hands have shaped temple doors, Kathakali motifs and intricate jewellery boxes. "
            "Every chisel stroke requires absolute concentration and reverence for the wood; we begin each new commission with a small prayer and a coconut. "
            "I never use power tools: each curve is sculpted by chisel and mallet, which is slower but leaves the living grain visible. "
            "My father taught me to read wood, to know which side of the trunk will crack and which will polish to a deep glow. "
            "The hardest period was after the temple restoration work dried up in the early 2000s; many carvers in our street sold their tools. "
            "Home decor and gifting demand slowly brought the craft back, and today our carved Ganeshas travel as far as Europe and Japan. "
            "My aspiration is to train apprentices from our own community so that Thrissur's temple style does not become a museum memory."
        ),
        "store": "Sita Woodcraft",
        "store_desc": "Hand-carved rosewood, teak and sandalwood crafts from Kerala using traditional chisel work.",
        "category": "Wooden Crafts",
        "craft_type": "Woodcarving",
        "products": [
            ("Rosewood Carved Jewellery Box", "Exquisite hand-carved rosewood jewellery box with intricate floral motifs, brass hinges and velvet-lined interior. Chola dynasty inspired carving on the lid.", 4200, 4800, 12, "Accessories", "Rosewood", "1.5kg", "25cm x 18cm x 12cm", ["Rosewood", "Jewellery Box", "Handcarved", "Kerala", "Gift"], True),
            ("Teak Wood Ganesh Statue", "Hand-carved teak wood Lord Ganesh statue in traditional Kerala temple style with ornate details. Each piece is individually carved over seven to ten days.", 6500, None, 6, "Statues", "Teak Wood", "2.5kg", "30cm x 20cm", ["Teak", "Ganesh", "Handcarved", "Temple Style", "Religious"], False),
            ("Rosewood Carved Wall Mirror Frame", "Hand-carved rosewood frame for a 30cm round mirror with vine and flower patterns inspired by Kerala temple architecture. Mirror not included.", 3200, 3600, 9, "Home Decor", "Rosewood", "2kg", "40cm x 40cm", ["Rosewood", "Mirror Frame", "Handcarved", "Temple Architecture"], False),
            ("Sandalwood Carved Elephant Pair", "Pair of small sandalwood elephants with saddle blankets carved in relief. Naturally fragrant, polished with beeswax only.", 2800, 3400, 15, "Showpiece", "Sandalwood", "600g", "12cm height each", ["Sandalwood", "Elephant", "Showpiece", "Fragrant", "Gift"], False),
        ],
    },
    {
        "key": "vikram",
        "name": "Vikram Rathore",
        "craft": "Woodcraft",
        "city": "Saharanpur",
        "state": "Uttar Pradesh",
        "years": 17,
        "verified": True,
        "bio": "Master woodcarver from Saharanpur producing intricately carved sheesham kitchenware, chess sets and home accents for three generations.",
        "story": (
            "Saharanpur's reputation for woodcarving rests on the hands of families like ours; my grandfather carved for the colonial-era export houses and my father continued after them. "
            "We work mostly in sheesham and mango wood, both seasoned for at least two years before a chisel touches them. "
            "Our signature is the deep relief floral border, copied from the old Mughal garden patterns that decorate Saharanpur's havelis. "
            "I run a workshop of eleven craftsmen, and we supply spice boxes, chess sets, trays and furniture inlays. "
            "The nineties were brutal: machine-carved pieces from industrial units undercut us badly and several karigars switched occupations. "
            "We survived by moving to finer, thinner work that machines could not copy cleanly, and by selling directly to design stores. "
            "Getting consistent quality sheesham is now the biggest headache as timber prices rise and supplies shrink. "
            "My aspiration is a design collaboration that keeps our carved borders but introduces forms for compact modern kitchens."
        ),
        "store": "Vikram Wood Works",
        "store_desc": "Saharanpur carved sheesham and mango wood kitchenware, chess sets and home accents.",
        "category": "Wooden Crafts",
        "craft_type": "Woodcarving",
        "products": [
            ("Wooden Spice Box with 7 Jars", "Hand-carved sheesham masala box with seven removable jars and a lift-off carved lid. Seasoned wood finished with food-safe oil.", 1800, 2200, 18, "Kitchen", "Sheesham Wood", "1.1kg", "22cm x 22cm x 8cm", ["Sheesham", "Spice Box", "Kitchen", "Carved", "Handmade"], True),
            ("Carved Wooden Chess Board", "Inlaid and carved sheesham chess board with hand-turned pieces. Mughal floral border carved in relief around the playing field.", 3400, 4000, 10, "Games", "Sheesham Wood", "2.8kg", "45cm x 45cm", ["Chess", "Sheesham", "Inlay", "Carved", "Games"], False),
            ("Sheesham Wood Jewelry Stand", "Three-tier carved jewelry stand in sheesham with earring rails and ring grooves. Natural oil finish shows the grain.", 1500, 1800, 22, "Accessories", "Sheesham Wood", "800g", "25cm height x 18cm width", ["Sheesham", "Jewelry Stand", "Carved", "Organiser"], False),
            ("Wooden Serving Tray Set of 2", "Pair of carved sheesham serving trays with brass-toned handles. Cutout floral handles and raised carved borders.", 1300, 1600, 26, "Kitchen", "Sheesham Wood", "1.4kg", "35cm x 25cm each", ["Sheesham", "Serving Tray", "Set of 2", "Kitchen", "Gift"], False),
        ],
    },
    {
        "key": "mahesh",
        "name": "Mahesh Chandra",
        "craft": "Channapatna Lacquer Woodcraft",
        "city": "Channapatna",
        "state": "Karnataka",
        "years": 19,
        "verified": True,
        "bio": "Channapatna toy maker from Karnataka crafting traditional lacquered wooden toys using lathe-turned ivory wood and natural lac colours.",
        "story": (
            "Channapatna, an hour from Bengaluru, is known as the town of toys; the craft is nearly two hundred years old and holds a geographical indication tag. "
            "I turn ivory wood, called aale mara, on a foot lathe and coat it with lac sticks coloured with natural dyes. "
            "The friction of the spinning wood melts the lac and fixes the colour in glossy rings, which is why no two toys carry identical patterns. "
            "My father and three uncles all made toys; at fourteen I joined them and learned that the real skill lies in seasoning the wood so it never splits in a child's hands. "
            "Plastic toys nearly wiped us out in the 1990s, and many artisans left for Bengaluru construction jobs. "
            "A revival backed by design schools and safety-certified natural lac has brought orders back, including export ones. "
            "Our biggest current challenge is toy-safety testing costs that small workshops struggle to afford. "
            "I aspire to start a shared testing and finishing unit for twenty Channapatna families so our toys can enter global markets without being priced out."
        ),
        "store": "Mahesh Lacquer Toys",
        "store_desc": "GI-tagged Channapatna lacquer wooden toys, lathe-turned from ivory wood with natural lac colours.",
        "category": "Wooden Crafts",
        "craft_type": "Lacquer Woodcraft",
        "products": [
            ("Channapatna Wooden Toy Cart", "Lathe-turned Channapatna toy cart in ivory wood with food-safe lac colours. Rolling wheels, smooth edges, GI-tagged craft from Karnataka.", 1200, 1500, 25, "Toys", "Ivory Wood with Lac", "400g", "20cm x 12cm", ["Channapatna", "Toy", "Lacquer", "GI Tag", "Kids"], True),
            ("Channapatna Lacquer Doll Set", "Set of four lathe-turned Channapatna dolls in bright lac colours. Traditional jointed forms, non-toxic finish.", 1800, 2200, 18, "Toys", "Ivory Wood with Lac", "600g", "15cm height each", ["Channapatna", "Doll Set", "Lacquer", "Toys"], False),
            ("Wooden Spinning Top Set (6)", "Set of six colourful Channapatna spinning tops with matching launch cords. Classic street-game toy, lathe-turned and lac-finished.", 700, 900, 40, "Toys", "Ivory Wood with Lac", "250g", "5cm diameter each", ["Channapatna", "Spinning Top", "Toys", "Affordable", "Gift"], False),
            ("Channapatna Wooden Kitchen Set", "Pretend-play kitchen set with carved pots, pans and ladles in Channapatna lacquer style. Child-safe rounded edges.", 2400, 2900, 14, "Toys", "Ivory Wood with Lac", "1.2kg", "Packed set 30cm box", ["Channapatna", "Kitchen Set", "Pretend Play", "Kids", "Lacquer"], False),
        ],
    },
    {
        "key": "ananya",
        "name": "Ananya Bose",
        "craft": "Kundan Jewellery",
        "city": "Kolkata",
        "state": "West Bengal",
        "years": 13,
        "verified": True,
        "bio": "Kundan and meenakari jewellery artist from Kolkata crafting bridal sets with hand-set stones, foil work and enamel backs in the Lucknow-Kolkata tradition.",
        "story": (
            "Kundan jewellery is the art of setting uncut stones in pure gold foil, and its meenakari back, the enamel work hidden against the skin, is where the real artistry lies. "
            "I trained under a karigar family in Kolkata's bow bazar jewellery lane for six years before starting my own bench. "
            "Each bridal set passes through four pairs of hands: the lac-core setter, the kundan placer, the enameller and the stringer. "
            "I work in silver-gold plated pieces with kundan stones and jadau technique so that bridal sets remain affordable for middle-class families, not only for royalty. "
            "The meenakari backs I paint myself, in the traditional peacock and lotus palettes of ruby red, parrot green and sky blue. "
            "The challenge is that customers now compare us with machine-made replicas selling online at a fraction of the price. "
            "We counter it with hallmark-style workshop stamps and lifetime re-polish promises. "
            "My aspiration is a small Kundan training studio for women in Kolkata, since very few young karigars are joining the trade."
        ),
        "store": "Ananya Kundan Jewels",
        "store_desc": "Hand-set Kundan and meenakari bridal jewellery from Kolkata in silver-gold plated jadau style.",
        "category": "Handmade Jewellery",
        "craft_type": "Kundan Jewellery",
        "products": [
            ("Kundan Bridal Necklace Set", "Hand-set kundan bridal necklace with matching jhumkas and maang tikka. Silver-gold plated, meenakari back, lac core setting. Six weeks of work.", 5800, 6900, 8, "Bridal Set", "Silver-Gold Plated with Kundan", "350g", "Necklace 42cm", ["Kundan", "Bridal", "Jadau", "Meenakari", "Wedding"], True),
            ("Kundan Jhumka Earrings", "Pair of hand-set kundan jhumka earrings with pearl drops and meenakari back enamel. Screw-back closures.", 1600, 1950, 24, "Earrings", "Silver-Gold Plated with Kundan", "60g", "5cm drop", ["Kundan", "Jhumka", "Earrings", "Festive"], False),
            ("Meenakari Kundan Choker", "Close-fitting kundan choker with full meenakari reverse enamel in peacock palette. Velcro-silk adjustable dori.", 3400, 4000, 12, "Choker", "Silver-Gold Plated with Kundan", "150g", "Adjustable 32-38cm", ["Kundan", "Choker", "Meenakari", "Peacock"], False),
            ("Kundan Maang Tikka", "Hand-set kundan maang tikka with single pearl drop and hook closure. Matches bridal sets or stands alone for festive wear.", 1200, 1450, 20, "Maang Tikka", "Silver-Gold Plated with Kundan", "40g", "6cm drop", ["Kundan", "Maang Tikka", "Festive", "Wedding"], False),
        ],
    },
    {
        "key": "priya",
        "name": "Priya Deshmukh",
        "craft": "Terracotta Jewellery",
        "city": "Pune",
        "state": "Maharashtra",
        "years": 10,
        "verified": True,
        "bio": "Terracotta jewellery maker from Pune hand-modelling tribal and contemporary clay pieces that are kiln-fired, hand-painted and cotton-cord finished.",
        "story": (
            "I discovered terracotta jewellery while recovering from an illness that kept me home for a year, and modelling clay became my therapy before it became my business. "
            "Every bead and pendant is hand-rolled from fine clay, dried, kiln-fired at stable temperature and then hand-painted with acrylics before a matte seal. "
            "My designs borrow from Warli figures, Bengali terracotta temple plaques and simple geometric tribal forms. "
            "Because terracotta is light, even large statement pieces stay comfortable, which is why my tribal necklaces sell so well at exhibitions. "
            "The first years were tough: uncontrolled firing cracked whole batches, and I lost festival-season orders twice. "
            "A proper temperature-controlled kiln changed everything, and now my breakage is under two percent. "
            "I source clay from Maharashtra potters and pay them directly rather than through traders. "
            "My aspiration is a terracotta jewellery design label that employs twenty women from Pune's outskirts and exports to diaspora markets."
        ),
        "store": "Priya Clay Jewels",
        "store_desc": "Hand-modelled terracotta jewellery from Pune: kiln-fired, hand-painted, tribal and contemporary.",
        "category": "Handmade Jewellery",
        "craft_type": "Terracotta Jewellery",
        "products": [
            ("Terracotta Beaded Necklace Set", "Hand-rolled terracotta bead necklace with matching earrings, kiln-fired and hand-painted in tribal motifs. Cotton cord adjustable.", 1400, 1700, 22, "Necklace Set", "Terracotta Clay", "120g", "Necklace 46cm", ["Terracotta", "Necklace", "Tribal", "Handmade", "Lightweight"], True),
            ("Terracotta Jhumka Earrings", "Pair of hand-modelled terracotta jhumkas with Warli-inspired painted details. Screw-back posts, matte sealed finish.", 700, 900, 40, "Earrings", "Terracotta Clay", "30g", "4cm drop", ["Terracotta", "Jhumka", "Warli", "Earrings", "Affordable"], False),
            ("Terracotta Tribal Bangles Set of 4", "Set of four hand-coiled terracotta bangles with carved tribal notches and matte colour. Sized to order, adjustable on request.", 1100, 1350, 26, "Bangles", "Terracotta Clay", "150g", "Inner diameter 6.5cm", ["Terracotta", "Bangles", "Tribal", "Set of 4"], False),
            ("Terracotta Pendant with Ear Drops", "Large hand-stamped terracotta pendant on waxed cotton cord with matching ear drops. Natural clay finish, no paint.", 650, 800, 35, "Pendant", "Terracotta Clay", "80g", "Pendant 5cm", ["Terracotta", "Pendant", "Natural", "Unpainted", "Gift"], False),
        ],
    },
    {
        "key": "arjun",
        "name": "Arjun Boro",
        "craft": "Bamboo & Cane Craft",
        "city": "Guwahati",
        "state": "Assam",
        "years": 15,
        "verified": True,
        "bio": "Eco-artisan from Assam crafting sustainable bamboo and cane furniture and home decor using traditional Bodo splitting and weaving techniques.",
        "story": (
            "In our village along the Brahmaputra, bamboo is life itself. "
            "I learned from the elders of the Bodo community how to select mature bamboo during autumn when sugar content is lowest, treat it naturally with water and smoke, and split it into strands as fine as thread. "
            "Every lampshade, basket and home decor piece I craft is fully biodegradable and carries the calm of Assam's forests. "
            "We use jati bamboo for structure and jati cane for binding, both harvested on rotation so clumps are never destroyed. "
            "The hardest years were the floods, which wiped out standing bamboo twice and pushed my family into debt. "
            "Organic fairs and now online sales have slowly rebuilt us. "
            "Design collaborations have introduced rattan-style lounge chairs and woven pendant lamps that sell well in city homes. "
            "My aspiration is a bamboo curing unit for our cluster so that we can add value locally instead of selling raw culms to factories in the plains."
        ),
        "store": "Arjun Bamboo Works",
        "store_desc": "Sustainable bamboo and cane products from Assam using traditional Bodo techniques.",
        "category": "Bamboo & Cane",
        "craft_type": "Bamboo & Cane",
        "products": [
            ("Handwoven Bamboo Basket Set (3)", "Set of three handwoven bamboo baskets in graduated sizes using traditional Assamese patterns. Perfect for kitchen storage or fruit display.", 1100, 1400, 35, "Storage", "Bamboo", "500g", "15cm, 20cm, 25cm diameter", ["Bamboo", "Basket", "Handwoven", "Kitchen", "Assam"], True),
            ("Bamboo Table Lamp", "Sustainable bamboo table lamp with handwoven shade casting beautiful shadow patterns when lit. Natural bamboo finish, standard E27 holder.", 1800, None, 18, "Lighting", "Bamboo", "800g", "35cm height x 20cm base", ["Bamboo", "Lamp", "Handwoven", "Sustainable", "Home Decor"], False),
            ("Bamboo Wind Chime", "Melodic bamboo wind chime with precision-tuned tubes and traditional Assamese cotton cord binding. Soothing natural sounds.", 650, 750, 40, "Garden", "Bamboo", "250g", "45cm length", ["Bamboo", "Wind Chime", "Garden", "Sustainable", "Gift"], False),
            ("Bamboo Serving Tray", "Woven bamboo serving tray with sturdy cane-wrapped handles. Lightweight, washable and ideal for chai service.", 900, 1100, 30, "Kitchen", "Bamboo with Cane", "450g", "35cm x 25cm", ["Bamboo", "Serving Tray", "Cane", "Kitchen"], False),
        ],
    },
    {
        "key": "gauri",
        "name": "Gauri Iyer",
        "craft": "Handloom Kanchipuram Silk",
        "city": "Kanchipuram",
        "state": "Tamil Nadu",
        "years": 21,
        "verified": True,
        "bio": "Third-generation Kanchipuram silk weaver from Tamil Nadu weaving contrast-border sarees with pure zari using the korvai joining technique.",
        "story": (
            "Kanchipuram weaving came into my blood through my mother, who sat at a pit loom in her parental home before marriage and continued here after it. "
            "Our sarees use three-ply mulberry silk and real zari, and the classic korvai technique joins the border and body with an interlocking weave that makes the join stronger than the fabric itself. "
            "A traditional temple-border bridal saree can take twenty-five to thirty days on the loom. "
            "I weave four sarees a month, which is considered efficient, and each carries our family mark in the pallu. "
            "The pandemic year was devastating: weddings were cancelled and entire looms sat idle. "
            "We survived by weaving silk stoles and cushion covers instead, and by selling through video calls to customers who had never bought silk online. "
            "The zari price rise of recent years worries us; some buyers now want lighter, cheaper sarees. "
            "My aspiration is a weaving collective of twenty women looms in our street, sharing design costs and selling under one trusted name."
        ),
        "store": "Gauri Silk Loom",
        "store_desc": "Handwoven Kanchipuram silk sarees and textiles with real zari and traditional korvai borders.",
        "category": "Handloom Textiles",
        "craft_type": "Handloom & Silk",
        "products": [
            ("Kanchipuram Silk Saree with Zari Border", "Pure three-ply mulberry silk Kanchipuram saree with contrast temple border woven in the korvai technique and real zari pallu. Comes with blouse piece.", 12500, 14500, 5, "Saree", "Pure Mulberry Silk with Zari", "800g", "550cm x 120cm", ["Kanchipuram", "Silk", "Zari", "Korvai", "Bridal"], True),
            ("Kanchipuram Silk Blouse Piece", "Matching pure silk blouse piece with zari border, woven in Kanchipuram. Unstitched, cut from the same loom as our sarees.", 2200, 2600, 15, "Blouse Piece", "Pure Mulberry Silk", "150g", "80cm x 100cm", ["Kanchipuram", "Silk", "Blouse Piece", "Zari"], False),
            ("Handloom Silk Stole", "Lightweight Kanchipuram silk stole with mini temple border, woven on our pit loom. Soft drape with subtle zari edge.", 2800, 3300, 18, "Stole", "Mulberry Silk Blend", "180g", "200cm x 65cm", ["Kanchipuram", "Stole", "Silk", "Handloom"], False),
            ("Kanchivaram Silk Cushion Cover Set", "Set of two silk cushion covers with korvai border strips and zari butis. Zip closure, cotton reverse.", 2400, 2900, 16, "Cushion Covers", "Mulberry Silk", "320g", "45cm x 45cm (set of 2)", ["Kanchipuram", "Cushion Cover", "Silk", "Home Decor"], False),
        ],
    },
    {
        "key": "kamla",
        "name": "Kamla Ben",
        "craft": "Bandhani & Leheriya",
        "city": "Bhuj",
        "state": "Gujarat",
        "years": 23,
        "verified": True,
        "bio": "Kutch bandhani artist from Bhuj tying thousands of tiny knots by hand to create classic tie-dye dupattas, gharcholas and leheriya stoles.",
        "story": (
            "Bandhani, from the Sanskrit 'bandh' meaning to tie, is the art of tying thousands of tiny points on cloth before dyeing, so that when the knots open, a constellation of dots remains. "
            "I learned from my mother and mother-in-law here in Bhuj's Bhadreshwar quarter, where whole families still tie for the Kutch wedding season. "
            "A single gharchola saree, grid-bordered in zari and dotted with bandhani across nine colours, can take a month of tying. "
            "We use pure georgette, chiffon and cotton, and natural as well as fast dyes depending on the customer. "
            "The 2001 earthquake destroyed our workshop and killed many artisans in our lane; rebuilding took years and we still feel that loss. "
            "Today Kutch bandhani faces cheap Rajasthani and Chinese imitations, which makes authentic work hard to sell without explanation. "
            "I now photograph the tying stage on my phone and send it to every buyer, which has ended most disputes. "
            "My aspiration is a bandhani archive documenting over sixty traditional patterns of Kutch before they are forgotten."
        ),
        "store": "Kamla Bandhani",
        "store_desc": "Hand-tied Kutch bandhani and leheriya textiles from Bhuj, Gujarat, in silk, georgette and cotton.",
        "category": "Handloom Textiles",
        "craft_type": "Bandhani Tie-Dye",
        "products": [
            ("Bandhani Silk Dupatta", "Hand-tied bandhani dupatta on pure silk with classic chandrokhani dot pattern in festive red and gold. Thousands of individual knots.", 2200, 2700, 18, "Dupatta", "Pure Silk", "200g", "230cm x 85cm", ["Bandhani", "Silk", "Dupatta", "Gujarat", "Hand-tied"], True),
            ("Leheriya Cotton Stole", "Diagonal leheriya tie-dye stole on soft cotton in monsoon-inspired blues. Hand-tied and dyed in Bhuj.", 1300, 1600, 26, "Stole", "Cotton", "150g", "200cm x 60cm", ["Leheriya", "Cotton", "Stole", "Tie-Dye"], False),
            ("Bandhani Gharchola Saree", "Traditional Gujarati gharchola saree: red bandhani field divided by gold zari grid, nine auspicious colours. Wedding-season classic.", 6500, 7800, 6, "Saree", "Georgette with Zari", "600g", "550cm x 120cm", ["Bandhani", "Gharchola", "Saree", "Wedding", "Zari"], False),
            ("Bandhani Cushion Cover Set", "Set of two bandhani cotton cushion covers with contrasting dot fields. Hidden zip, hand-tied in our Bhuj workshop.", 1500, 1800, 24, "Cushion Covers", "Cotton", "280g", "45cm x 45cm (set of 2)", ["Bandhani", "Cushion Cover", "Home Decor", "Cotton"], False),
        ],
    },
]


# ============================================================================
# DEMO B2B BUYERS + ORDERS
# ============================================================================

BUYERS = [
    ("demo.buyer1@hastkala.example", "Aarav Traders", "Mumbai", "Maharashtra"),
    ("demo.buyer2@hastkala.example", "Nandini Handicrafts Emporium", "Bengaluru", "Karnataka"),
]

# (product_artisan_key, product_index, qty, per_piece, status, lead_days, delivery_city, days_ago)
ORDERS = [
    ("ramesh", 1, 40, 3500, "confirmed", 21, "Mumbai", 12),
    ("kavita", 1, 2, 8500, "production", 30, "Delhi", 18),
    ("sitanair", 2, 10, 6500, "shipped", 15, "Bengaluru", 26),
    ("ananya", 1, 5, 5800, "delivered", 25, "Hyderabad", 40),
    ("sandeep", 1, 25, 3600, "production", 20, "Kolkata", 9),
    ("vikram", 1, 50, 1800, "confirmed", 14, "Pune", 6),
    ("gauri", 1, 3, 12500, "shipped", 35, "Chennai", 21),
    ("arjun", 1, 60, 1100, "delivered", 12, "Guwahati", 33),
]

SAVED = [
    ("demo.buyer1@hastkala.example", "ramesh"),
    ("demo.buyer1@hastkala.example", "kavita"),
    ("demo.buyer1@hastkala.example", "ananya"),
    ("demo.buyer2@hastkala.example", "sitanair"),
    ("demo.buyer2@hastkala.example", "gauri"),
    ("demo.buyer2@hastkala.example", "sandeep"),
]


# ============================================================================
# HELPERS
# ============================================================================


def existing_ids(sb, table: str, ids: list[str]) -> set[str]:
    found: set[str] = set()
    ids = [i for i in ids if i]
    for i in range(0, len(ids), 200):
        chunk = ids[i : i + 200]
        rows = sb.table(table).select("id").in_("id", chunk).execute().data or []
        found.update(r["id"] for r in rows)
    return found


def get_or_create_users(sb, specs: list[dict]) -> dict[str, str]:
    """email -> user_id. Uses Supabase Auth admin API (best effort)."""
    emails = [s["email"] for s in specs]
    known: dict[str, str] = {}
    try:
        page = 1
        while True:
            users = sb.auth.admin.list_users(page=page, per_page=200) or []
            if not users:
                break
            for u in users:
                em = getattr(u, "email", None) or (u.get("email") if isinstance(u, dict) else None)
                uid = getattr(u, "id", None) or (u.get("id") if isinstance(u, dict) else None)
                if em and uid and em in emails:
                    known[em] = uid
            if len(users) < 200:
                break
            page += 1
    except Exception as e:
        print(f"  ! list_users failed ({e}); will try create_user only")

    for s in specs:
        if s["email"] in known:
            continue
        try:
            resp = sb.auth.admin.create_user(
                {
                    "email": s["email"],
                    "password": DEMO_PASSWORD,
                    "email_confirm": True,
                    "user_metadata": {"name": s["meta_name"], "role": s["role"], "demo": True},
                }
            )
            uid = getattr(resp, "user", resp)
            uid = getattr(uid, "id", None) or (uid.get("id") if isinstance(uid, dict) else None)
            if uid:
                known[s["email"]] = uid
        except Exception as e:
            msg = str(e)
            if "already been registered" in msg or "already_exists" in msg.lower():
                print(f"  ~ auth user already exists: {s['email']}")
            else:
                print(f"  ! create_user failed for {s['email']}: {e}")
    return known


# ============================================================================
# BUILD ROWS
# ============================================================================


def build_rows():
    artisan_rows, store_rows, product_rows = [], [], []
    key_to_artisan_id: dict[str, str] = {}
    key_to_store_id: dict[str, str] = {}
    product_index: dict[tuple[str, int], tuple[str, str]] = {}  # (key, 1-based i) -> (product_id, name)

    for ai, a in enumerate(ARTISANS, start=1):
        aid = hid("artisan", a["key"])
        sid = hid("store", a["key"])
        key_to_artisan_id[a["key"]] = aid
        key_to_store_id[a["key"]] = sid
        n_products = len(a["products"])
        artisan_rows.append(
            {
                "id": aid,
                "user_id": None,  # filled later if auth user created
                "name": a["name"],
                "avatar_url": avatar_url(a["name"], ai),
                "bio": a["bio"],
                "craft_specialization": a["craft"],
                "location": a["city"],
                "state": a["state"],
                "years_of_experience": a["years"],
                "craft_story": a["story"],
                "is_verified": a["verified"],
                "created_at": days_ago(30 + ai * 3),
                "followers_count": 120 + ai * 17,
                "products_count": n_products,
                "average_rating": round(4.4 + (ai % 6) * 0.1, 1),
                "total_reviews": 18 + ai * 4,
            }
        )
        store_rows.append(
            {
                "id": sid,
                "artisan_id": aid,
                "name": a["store"],
                "slug": a["key"] + "-store",
                "description": a["store_desc"],
                "logo_url": avatar_url(a["name"], ai + 5),
                "banner_url": IMG[a["category"]][ai % len(IMG[a["category"]])],
                "craft_category": a["category"],
                "location": a["city"],
                "state": a["state"],
                "average_rating": round(4.4 + (ai % 6) * 0.1, 1),
                "total_reviews": 18 + ai * 4,
                "total_products": n_products,
                "total_sales": 40 + ai * 9,
                "total_followers": 120 + ai * 17,
                "is_verified": a["verified"],
                "is_active": True,
                "created_at": days_ago(30 + ai * 3),
            }
        )
        pool = IMG[a["category"]]
        for pi, p in enumerate(a["products"], start=1):
            name, desc, price, mrp, stock, subcat, material, weight, dims, tags, featured = p
            pid = hid("product", f"{a['key']}:{pi}")
            product_index[(a["key"], pi)] = (pid, name)
            imgs = [pool[(pi - 1) % len(pool)]] + ([pool[pi % len(pool)]] if len(pool) > 1 else [])
            product_rows.append(
                {
                    "id": pid,
                    "store_id": sid,
                    "artisan_id": aid,
                    "name": name,
                    "description": desc,
                    "price": float(price),
                    "discount_price": float(mrp) if mrp else None,
                    "category": a["category"],
                    "subcategory": subcat,
                    "image_urls": imgs,
                    "variants": [],
                    "stock_quantity": stock,
                    "is_published": True,
                    "is_featured": featured,
                    "craft_type": a["craft_type"],
                    "material": material,
                    "weight": weight,
                    "dimensions": dims,
                    "shipping_info": "Free shipping across India. Packed with care by the artisan.",
                    "tags": tags,
                    "average_rating": round(4.3 + (pi % 7) * 0.1, 1),
                    "total_reviews": 6 + pi * 3 + ai,
                    "total_sales": stock - (pi * 2),
                    "views": 90 + ai * 13 + pi * 27,
                    "status": "approved",
                    "visibility": "public",
                    "created_at": days_ago(5 + pi * 4 + ai),
                }
            )
    return artisan_rows, store_rows, product_rows, key_to_artisan_id, key_to_store_id, product_index


def main() -> int:
    print("=" * 70)
    print("HastKala demo data seeder")
    print("=" * 70)
    sb, key_label = get_client()
    is_service_role = key_label == "service-role"
    print(f"Supabase key: {key_label}")
    artisan_rows, store_rows, product_rows, a2id, s2id, pindex = build_rows()

    artisan_ids = [r["id"] for r in artisan_rows]
    store_ids = [r["id"] for r in store_rows]
    product_ids = [r["id"] for r in product_rows]
    order_ids = [hid("order", str(i)) for i in range(1, len(ORDERS) + 1)]
    saved_ids = [hid("saved", f"{e}:{k}") for e, k in SAVED]

    print(f"\nPlan: {len(artisan_rows)} artisans, {len(store_rows)} stores, {len(product_rows)} products, "
          f"{len(ORDERS)} b2b orders, {len(SAVED)} saved-artisan links")
    print("Idempotency: deterministic uuid5 ids, insert-only (existing ids skipped, nothing deleted)\n")

    if DRY_RUN:
        print("[dry-run] no writes performed.")
        return 0

    ex_artisan = existing_ids(sb, "artisans", artisan_ids)
    ex_store = existing_ids(sb, "stores", store_ids)
    ex_product = existing_ids(sb, "products", product_ids)
    ex_order = existing_ids(sb, "b2b_orders", order_ids)
    ex_saved = existing_ids(sb, "b2b_saved_artisans", saved_ids)

    # ---- auth users (only possible with a service-role key) ----
    users: dict[str, str] = {}
    if is_service_role:
        print("Auth users (fictional @hastkala.example accounts, password: %s):" % DEMO_PASSWORD)
        artisan_specs = [
            {"email": f"artisan{i:02d}.demo@hastkala.example", "meta_name": a["name"], "role": "artisan"}
            for i, a in enumerate(ARTISANS, start=1)
        ]
        buyer_specs = [
            {"email": e, "meta_name": n, "role": "buyer"} for e, n, _city, _st in BUYERS
        ]
        users = get_or_create_users(sb, artisan_specs + buyer_specs)
        print(f"  auth users available: {len(users)}")
    else:
        print("Auth users: skipped (no valid service-role key in backend/.env).")
        print("  -> artisan.user_id stays NULL (same as backend/database/seed_demo.sql).")
        print("  -> b2b demo orders / saved artisans are skipped; re-run with a valid")
        print("     SUPABASE_SECRET_KEY (Supabase -> Settings -> API) to create them.")

    for a, row in zip(ARTISANS, artisan_rows):
        email = f"artisan{ARTISANS.index(a) + 1:02d}.demo@hastkala.example"
        row["user_id"] = users.get(email)

    # ---- insert missing rows ----
    def insert_missing(table: str, rows: list[dict], already: set[str]) -> int:
        missing = [r for r in rows if r["id"] not in already]
        for i in range(0, len(missing), 25):
            sb.table(table).insert(missing[i : i + 25]).execute()
        return len(missing)

    if not is_service_role:
        for r in artisan_rows:
            r["user_id"] = None

    n_artisan = insert_missing("artisans", artisan_rows, ex_artisan)
    n_store = insert_missing("stores", store_rows, ex_store)
    n_product = insert_missing("products", product_rows, ex_product)
    print(f"\nInserted: artisans={n_artisan} (skipped {len(artisan_rows) - n_artisan}), "
          f"stores={n_store} (skipped {len(store_rows) - n_store}), "
          f"products={n_product} (skipped {len(product_rows) - n_product})")

    if REFRESH_IMAGES:
        # Update images ONLY on our deterministic demo rows (never touches user data).
        def refresh(table: str, rows: list[dict], fields: list[str]) -> int:
            n = 0
            for i in range(0, len(rows), 25):
                chunk = rows[i : i + 25]
                for r in chunk:
                    sb.table(table).update({k: r[k] for k in fields}).eq("id", r["id"]).execute()
                    n += 1
            return n

        na = refresh("artisans", artisan_rows, ["avatar_url"])
        ns = refresh("stores", store_rows, ["logo_url", "banner_url"])
        np_ = refresh("products", product_rows, ["image_urls"])
        print(f"Refreshed images -> artisans={na}, stores={ns}, products={np_}")

    buyer_id_by_email = {e: users.get(e) for e, *_ in BUYERS}
    order_rows = []
    for i, (akey, pidx, qty, per, status, lead, city, dag) in enumerate(ORDERS, start=1):
        pid, pname = pindex[(akey, pidx)]
        buyer_emails = [e for e, *_ in BUYERS]
        buyer = buyer_id_by_email.get(buyer_emails[(i - 1) % len(buyer_emails)])
        if not buyer:
            print(f"  ~ order {i} skipped (no auth user for buyer)")
            continue
        order_rows.append(
            {
                "id": hid("order", str(i)),
                "buyer_id": buyer,
                "artisan_id": a2id[akey],
                "product_id": pid,
                "product_name": pname,
                "quantity": qty,
                "price_per_piece": float(per),
                "total_amount": float(qty * per),
                "lead_time_days": lead,
                "delivery_location": city,
                "status": status,
                "artisan_message": "Demo order created by seed script for development testing.",
                "created_at": days_ago(dag),
            }
        )
    n_order = insert_missing("b2b_orders", order_rows, ex_order)

    saved_rows = []
    for e, akey in SAVED:
        buyer = buyer_id_by_email.get(e)
        if not buyer:
            continue
        saved_rows.append(
            {
                "id": hid("saved", f"{e}:{akey}"),
                "buyer_id": buyer,
                "artisan_id": a2id[akey],
                "created_at": days_ago(10),
            }
        )
    n_saved = insert_missing("b2b_saved_artisans", saved_rows, ex_saved)
    print(f"Inserted: b2b_orders={n_order} (skipped {len(order_rows) - n_order}), "
          f"saved_artisans={n_saved} (skipped {len(saved_rows) - n_saved})")

    # ---- verification ----
    print("\n" + "=" * 70)
    print("VERIFICATION")
    print("=" * 70)
    total_art = sb.table("artisans").select("id", count="exact").execute()
    total_sto = sb.table("stores").select("id", count="exact").execute()
    total_prod = sb.table("products").select("id", count="exact").execute()
    total_ord = sb.table("b2b_orders").select("id", count="exact").execute()
    print(f"DB totals  -> artisans={total_art.count}  stores={total_sto.count}  "
          f"products={total_prod.count}  b2b_orders={total_ord.count}")

    seeded_products = (
        sb.table("products").select("id, artisan_id, store_id, name, category, price")
        .in_("id", product_ids).limit(500).execute().data or []
    )
    orphan = [p for p in seeded_products if p["artisan_id"] not in a2id.values() or p["store_id"] not in s2id.values()]
    print(f"Seeded products loaded for check: {len(seeded_products)}, orphans: {len(orphan)}")

    cats = sorted({p["category"] for p in seeded_products})
    print(f"Categories ({len(cats)}): {', '.join(cats)}")

    art_with_story = (
        sb.table("artisans").select("id, name, craft_story, location, state")
        .in_("id", artisan_ids).limit(100).execute().data or []
    )
    short_stories = [r["name"] for r in art_with_story if len(r.get("craft_story") or "") < 150]
    print(f"Artisans with 150+ word stories: {len(art_with_story) - len(short_stories)}/{len(art_with_story)}")

    sample = seeded_products[:3]
    print("\nSample product -> artisan relationships:")
    name_by_id = {r["id"]: r["name"] for r in art_with_story}
    for p in sample:
        print(f"  - {p['name']} (Rs {p['price']}, {p['category']}) by {name_by_id.get(p['artisan_id'], '?')}")

    if users:
        print("\nLogin accounts (dev only):")
        print("  artisans: artisan01.demo@hastkala.example .. artisan18.demo@hastkala.example")
        print(f"  buyers:   {', '.join(e for e, *_ in BUYERS)}")
        print(f"  password: {DEMO_PASSWORD}")
    else:
        print("\nLogin accounts: not created (service-role key unavailable this run).")
    print("\nNote: schema has no reviews/categories tables; ratings live in "
          "average_rating/total_reviews columns and categories are derived from products.category.")
    print("Done. Script is re-runnable and never deletes or overwrites existing data.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
