import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hastkala/core/services/api_config.dart';
import 'package:hastkala/core/services/data_service.dart';
import 'package:hastkala/core/models/models.dart';
import 'package:hastkala/features/products/models/product_draft.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Product Publish & Persistence Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('ApiConfig candidateUrls contains configured backend IP', () {
      final urls = ApiConfig.candidateUrls;
      expect(urls, isNotEmpty);
      expect(urls.any((u) => u.contains(':8000')), isTrue);
    });

    test('DataService publishes ProductDraft and displays in products list', () async {
      final data = DataService();
      await data.init();

      final initialCount = data.products.length;
      final initialMockCount = MockArtisanProducts.all.length;

      final draft = ProductDraft(
        productName: 'Handcrafted Terracotta Pot',
        category: 'Pottery & Ceramics',
        craft: 'Terracotta Craft',
        material: 'Terracotta Clay',
        price: 850,
        craftStory: 'Made by traditional artisan with hand-painted motifs.',
        location: 'Jaipur, Rajasthan',
        artisanName: 'Ramesh Kumar',
      );

      final publishedProduct = await data.publishProductDraft(draft);

      expect(publishedProduct.name, 'Handcrafted Terracotta Pot');
      expect(publishedProduct.price, 850.0);
      expect(data.products.length, initialCount + 1);
      expect(data.products.first.id, publishedProduct.id);
      expect(MockArtisanProducts.all.length, initialMockCount + 1);
      expect(MockArtisanProducts.all.first.product.name, 'Handcrafted Terracotta Pot');
    });

    test('Adaptive image resolver handles relative and absolute paths', () {
      expect(ApiConfig.resolveImageUrl('https://example.com/image.jpg'), 'https://example.com/image.jpg');
      expect(ApiConfig.resolveImageUrl('assets/logo.png'), 'assets/logo.png');
      expect(ApiConfig.resolveImageUrl('/uploads/test.jpg'), contains('/uploads/test.jpg'));
    });
  });
}
