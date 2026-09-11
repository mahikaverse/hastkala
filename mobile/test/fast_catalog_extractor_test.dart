import 'package:flutter_test/flutter_test.dart';
import 'package:hastkala/core/services/fast_catalog_extractor.dart';

void main() {
  group('FastCatalogExtractor Tests', () {
    test('Extracts pottery details from Hindi transcript', () {
      const transcript =
          'Mera naam Ramesh hai. Ye mitti ka ek decorative matka hai, hand painted blue color ka. Iska size medium hai aur vajan lagbhag 500 gram hai. Humne isko 3 din mein banaya hai traditional clay art se. Iski keemat 850 rupaye hai. Hum Jaipur ke rahne wale hain.';

      final result = FastCatalogExtractor.extract(transcript);

      expect(result['material'], 'Clay');
      expect(result['color'], 'Blue');
      expect(result['size'], 'Medium');
      expect(result['weight'], '500 gram');
      expect(result['making_time'], '3 days');
      expect(result['price'], 850);
      expect(result['location'], 'Jaipur');
      expect(result['category'], 'Pottery & Ceramics');
      expect(result['craft'], 'Hand Painted');
      expect(result['product_name'], contains('Decorative Pot'));
    });

    test('Extracts bamboo basket details', () {
      const transcript =
          'Ye bamboo se bani hui fruit basket hai. Handcrafted hai green color ki. 12 inch size hai. Isko banane mein 2 din lage. Price 450 rupees.';

      final result = FastCatalogExtractor.extract(transcript);

      expect(result['material'], 'Bamboo');
      expect(result['color'], 'Green');
      expect(result['size'], '12 inch');
      expect(result['making_time'], '2 days');
      expect(result['price'], 450);
      expect(result['category'], 'Bamboo & Cane');
    });

    test('Extracts handloom silk saree from Banaras', () {
      const transcript =
          'Humne pure silk saree banayi hai handloom se, red and gold color. Banaras ki famous craft hai. 5 din ka time laga. Price is 4500.';

      final result = FastCatalogExtractor.extract(transcript);

      expect(result['material'], 'Silk');
      expect(result['color'], anyOf('Red', 'Gold'));
      expect(result['making_time'], '5 days');
      expect(result['price'], 4500);
      expect(result['category'], 'Textiles & Handloom');
      expect(result['location'], 'Banaras');
    });
  });
}
