from app.ai.price_assistant import _calculate_pricing_logic, _sanitize_price, _round_to_rupee
from app.schemas.pricing import ComparableProduct, PriceSuggestionRequest
from app.ai.price_assistant import suggest_price


class TestPricingCalculations:
    def test_sanitize_price(self):
        assert _sanitize_price(750) == 750
        assert _sanitize_price("850") == 850
        assert _sanitize_price("₹ 1,200") == 1200
        assert _sanitize_price(-10) is None
        assert _sanitize_price("abc") is None

    def test_round_to_rupee(self):
        assert _round_to_rupee(720) == 700
        assert _round_to_rupee(735) == 750
        assert _round_to_rupee(840) == 850
        assert _round_to_rupee(10) == 50

    def test_calculation_with_comparables(self):
        artisan_expected = 700
        comparables = [
            ComparableProduct(title="Vase A", price=800, source="Jaypore"),
            ComparableProduct(title="Vase B", price=950, source="Itokri"),
            ComparableProduct(title="Vase C", price=1000, source="Craftsvilla"),
        ]
        res = _calculate_pricing_logic(
            artisan_expected=artisan_expected,
            comparables=comparables,
            craft="Blue Pottery",
            material="Clay",
            product_name="Vase",
        )
        assert res["comparables_found"] == 3
        assert res["market_min"] <= res["suggested_price"] <= res["market_max"]
        assert res["recommended_min"] <= res["suggested_price"] <= res["recommended_max"]
        assert res["suggested_price"] >= artisan_expected

    def test_calculation_without_comparables(self):
        artisan_expected = 700
        res = _calculate_pricing_logic(
            artisan_expected=artisan_expected,
            comparables=[],
        )
        assert res["comparables_found"] == 0
        assert res["suggested_price"] == artisan_expected
        assert res["recommended_min"] <= res["suggested_price"] <= res["recommended_max"]
        assert "couldn't find enough similar products" in res["reason"].lower()

    def test_suggest_price_service(self):
        req = PriceSuggestionRequest(
            product_name="Clay Pot",
            craft="Pottery",
            artisan_expected_price=500,
        )
        resp = suggest_price(req)
        assert resp.success is True
        assert resp.artisan_expected_price == 500
        assert resp.suggested_price > 0
        assert resp.market_min <= resp.market_max
        assert resp.recommended_min <= resp.recommended_max


if __name__ == "__main__":
    t = TestPricingCalculations()
    t.test_sanitize_price()
    t.test_round_to_rupee()
    t.test_calculation_with_comparables()
    t.test_calculation_without_comparables()
    t.test_suggest_price_service()
    print("All pricing unit tests passed successfully!")
