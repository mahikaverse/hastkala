import pytest
from httpx import ASGITransport, AsyncClient

from app.ai.catalog_extractor import extract_product_details, check_ollama_health
from app.main import app


@pytest.fixture(scope="module")
def check_ollama():
    health = check_ollama_health()
    if not health["available"]:
        pytest.skip("Ollama not available — skipping integration tests")
    return health


class TestExtractProductDetails:
    def test_hindi_transcript(self, check_ollama):
        transcript = (
            "Ye bamboo basket hai. Bamboo se haath se banaya hai. "
            "Isko banane mein 3 din lagte hain. Main Bihar mein rehti hoon. "
            "Ye craft maine apni maa se seekha hai."
        )
        result = extract_product_details(transcript)
        assert result.material == "Bamboo"
        assert result.making_time is not None
        assert result.location is not None

    def test_english_transcript(self, check_ollama):
        transcript = (
            "This is a handwoven cotton scarf. I made it in Jaipur, Rajasthan. "
            "It took me 2 days to complete. I sell it for 500 rupees."
        )
        result = extract_product_details(transcript)
        assert result.material == "Cotton"
        assert result.making_time is not None
        assert result.price is not None

    def test_mixed_hindi_english_transcript(self, check_ollama):
        transcript = (
            "Ye blue bamboo basket hai. Iska size 12 inch hai. "
            "Maine ise banane mein 3 din lagaye. Iski keemat 850 rupaye hai."
        )
        result = extract_product_details(transcript)
        assert result.color is not None
        assert result.material == "Bamboo"
        assert result.size is not None
        assert result.making_time is not None
        assert result.price is not None

    def test_missing_fields_return_none(self, check_ollama):
        transcript = "This is a simple handmade item."
        result = extract_product_details(transcript)
        dumped = result.model_dump()
        null_fields = [k for k, v in dumped.items() if v is None]
        assert len(null_fields) >= 5, f"Expected many null fields, got: {null_fields}"

    def test_transcript_with_price(self, check_ollama):
        transcript = (
            "This terracotta pot is from West Bengal. "
            "The price is 1200 rupees. It weighs 2 kg."
        )
        result = extract_product_details(transcript)
        assert result.price is not None
        assert result.weight is not None
        assert result.material == "Terracotta"

    def test_transcript_with_size_and_quantity(self, check_ollama):
        transcript = (
            "I have 5 pieces of handwoven wool shawls from Kashmir. "
            "Each shawl is 200 cm x 80 cm in size."
        )
        result = extract_product_details(transcript)
        assert result.quantity is not None
        assert result.size is not None
        assert result.material == "Wool"


class TestAPIEndpoint:
    @pytest.mark.asyncio
    async def test_extract_hindi(self, check_ollama):
        transport = ASGITransport(app=app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            resp = await client.post(
                "/api/ai/extract-product-details",
                json={"transcript": "Ye bamboo basket hai. Bihar mein banaya hai."},
            )
            assert resp.status_code == 200
            body = resp.json()
            assert body["success"] is True
            assert body["data"] is not None
            assert body["data"]["material"] == "Bamboo"

    @pytest.mark.asyncio
    async def test_extract_empty_transcript(self, check_ollama):
        transport = ASGITransport(app=app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            resp = await client.post(
                "/api/ai/extract-product-details",
                json={"transcript": "   "},
            )
            assert resp.status_code == 422

    @pytest.mark.asyncio
    async def test_extract_english(self, check_ollama):
        transport = ASGITransport(app=app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            resp = await client.post(
                "/api/ai/extract-product-details",
                json={"transcript": "This is a silk painting from Rajasthan. Price is 2000 rupees."},
            )
            assert resp.status_code == 200
            body = resp.json()
            assert body["success"] is True
            assert body["data"]["material"] == "Silk"
