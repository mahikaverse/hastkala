import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.schemas.b2b import B2BRequirementMatchRequest
from app.ai.b2b_matcher import match_requirement_with_groq, _local_fallback_match, fetch_all_artisans


class TestB2BMatcher:
    def test_fetch_artisans(self):
        artisans = fetch_all_artisans()
        assert len(artisans) >= 5
        names = [a["name"] for a in artisans]
        assert "Meera Devi" in names
        assert "Ramesh Kumar" in names

    def test_local_fallback_matching_pottery(self):
        artisans = fetch_all_artisans()
        req = B2BRequirementMatchRequest(
            title="500 Blue pottery cups",
            category="Pottery & Ceramics",
            quantity=500,
            delivery_location="Jaipur",
            description="Need glazed ceramic cups for restaurant",
        )
        res = _local_fallback_match(req, artisans)
        assert res.success is True
        assert len(res.matches) >= 5
        top = res.matches[0]
        assert "pottery" in top.craft_specialization.lower()
        assert top.match_score >= 80

    def test_local_fallback_matching_silk(self):
        artisans = fetch_all_artisans()
        req = B2BRequirementMatchRequest(
            title="100 Banarasi Silk Sarees",
            category="Textiles & Handloom",
            quantity=100,
            delivery_location="Varanasi",
            description="Need authentic handloom silk sarees with gold zari border",
        )
        res = _local_fallback_match(req, artisans)
        assert res.success is True
        top = res.matches[0]
        assert "Kavita Sharma" in top.artisan_name or "Handloom" in top.craft_specialization
        assert top.match_score >= 80

    def test_match_requirement_service(self):
        req = B2BRequirementMatchRequest(
            title="200 Wooden jewelry boxes",
            category="Woodwork",
            material="Rosewood",
            quantity=200,
            deadline="3 weeks",
            delivery_location="Kerala",
            description="Intricately carved wooden keepsake boxes",
        )
        res = match_requirement_with_groq(req)
        assert res.success is True
        assert len(res.matches) > 0
        assert res.matches[0].match_score > 50
        assert len(res.matches[0].match_reason) > 10


if __name__ == "__main__":
    t = TestB2BMatcher()
    t.test_fetch_artisans()
    t.test_local_fallback_matching_pottery()
    t.test_local_fallback_matching_silk()
    t.test_match_requirement_service()
    print("All B2B AI matcher tests passed successfully!")
