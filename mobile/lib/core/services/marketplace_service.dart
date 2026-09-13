import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/listing_data.dart';
import '../models/marketplace_template.dart';
import '../models/marketplace_product.dart';
import 'api_config.dart';

class MarketplaceService {
  static final MarketplaceService _instance = MarketplaceService._internal();
  factory MarketplaceService() => _instance;
  MarketplaceService._internal();

  ListingData mapProductToMarketplace(
    MarketplaceProduct product,
    MarketplaceTemplate template,
  ) {
    final color = product.variants.isNotEmpty ? product.variants.first.value : '';

    final listing = ListingData(
      productId: product.id,
      productName: product.name,
      title: product.name,
      description: product.description,
      bulletPoints: _buildBulletPoints(product),
      keywords: product.tags,
      category: product.category.isNotEmpty ? product.category : product.subcategory,
      material: product.material ?? '',
      craftType: product.craftType ?? '',
      color: color,
      size: product.dimensions ?? '',
      weight: product.weight ?? '',
      dimensions: product.dimensions ?? '',
      price: product.effectivePrice,
      mrp: product.price,
      stockQuantity: product.stockQuantity,
      brand: 'HastKala Artisan',
    );

    return validateListing(listing, template);
  }

  List<String> _buildBulletPoints(MarketplaceProduct product) {
    final bullets = <String>[];
    if (product.material != null && product.material!.isNotEmpty) {
      bullets.add('Material: ${product.material}');
    }
    if (product.craftType != null && product.craftType!.isNotEmpty) {
      bullets.add('Craft: ${product.craftType}');
    }
    if (product.dimensions != null && product.dimensions!.isNotEmpty) {
      bullets.add('Size: ${product.dimensions}');
    }
    if (product.weight != null && product.weight!.isNotEmpty) {
      bullets.add('Weight: ${product.weight}');
    }
    if (product.category.isNotEmpty) {
      bullets.add('Category: ${product.category}');
    }
    return bullets;
  }

  ListingData validateListing(ListingData listing, MarketplaceTemplate template) {
    final missing = <String>[];

    if (listing.title.trim().isEmpty) missing.add('title');
    if (listing.description.trim().isEmpty) missing.add('description');
    if (listing.category.trim().isEmpty) missing.add('category');
    if (listing.material.trim().isEmpty) missing.add('material');
    if (listing.price <= 0) missing.add('price');

    if (template.requiredFields.contains('bulletPoints') && listing.bulletPoints.isEmpty) {
      missing.add('bulletPoints');
    }
    if (template.requiredFields.contains('keywords') && listing.keywords.isEmpty) {
      missing.add('keywords');
    }

    return listing.copyWith(missingFields: missing);
  }

  Future<ListingData?> prepareListingWithAI(
    ListingData listing,
    MarketplaceTemplate template,
  ) async {
    try {
      final result = await _callBackend(listing, template);
      if (result != null) return result;
    } catch (_) {}

    return _callGroqDirect(listing, template);
  }

  Future<ListingData?> _callBackend(ListingData listing, MarketplaceTemplate template) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/ai/prepare-marketplace-listing');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'product_name': listing.productName,
        'description': listing.description,
        'material': listing.material,
        'craft_type': listing.craftType,
        'category': listing.category,
        'price': listing.price,
        'color': listing.color,
        'size': listing.size,
        'weight': listing.weight,
        'dimensions': listing.dimensions,
        'marketplace': template.id,
        'existing_bullet_points': listing.bulletPoints,
        'existing_keywords': listing.keywords,
      }),
    ).timeout(const Duration(seconds: 30));

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      if (data['success'] == true && data['listing'] != null) {
        return _applyAIResult(listing, data['listing'], template);
      }
    }
    return null;
  }

  Future<ListingData?> _callGroqDirect(ListingData listing, MarketplaceTemplate template) async {
    final apiKey = ApiConfig.groqApiKey;
    if (apiKey.isEmpty) return null;

    final userPrompt = _buildUserPrompt(listing);
    String? responseText;

    try {
      final resp = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'qwen/qwen3.8-27b',
          'messages': [
            {'role': 'system', 'content': template.aiSystemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': 0.7,
          'max_tokens': 800,
        }),
      ).timeout(const Duration(seconds: 30));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        responseText = data['choices']?[0]?['message']?['content']?.toString().trim();
      }
    } catch (_) {}

    if (responseText == null || responseText.isEmpty) return null;

    final jsonStr = _extractJson(responseText);
    if (jsonStr == null) return null;

    try {
      final aiData = jsonDecode(jsonStr) as Map<String, dynamic>;
      return _applyAIResult(listing, aiData, template);
    } catch (_) {
      return null;
    }
  }

  String _buildUserPrompt(ListingData listing) {
    final parts = <String>[
      'Product: ${listing.productName}',
      'Description: ${listing.description.isNotEmpty ? listing.description : "N/A"}',
      'Material: ${listing.material.isNotEmpty ? listing.material : "N/A"}',
      'Craft: ${listing.craftType.isNotEmpty ? listing.craftType : "N/A"}',
      'Category: ${listing.category.isNotEmpty ? listing.category : "N/A"}',
      'Price: ₹${listing.price.toInt()}',
      'Color: ${listing.color.isNotEmpty ? listing.color : "N/A"}',
      'Size: ${listing.size.isNotEmpty ? listing.size : "N/A"}',
      'Weight: ${listing.weight.isNotEmpty ? listing.weight : "N/A"}',
    ];
    if (listing.bulletPoints.isNotEmpty) {
      parts.add('Existing features: ${listing.bulletPoints.join(", ")}');
    }
    if (listing.keywords.isNotEmpty) {
      parts.add('Existing tags: ${listing.keywords.join(", ")}');
    }
    return parts.join('\n');
  }

  String? _extractJson(String text) {
    final codeBlockPattern = RegExp(r'```(?:json)?\s*\n?(.*?)\n?```', dotAll: true);
    final match = codeBlockPattern.firstMatch(text);
    if (match != null) return match.group(1)?.trim();

    final jsonPattern = RegExp(r'\{.*\}', dotAll: true);
    final jsonMatch = jsonPattern.firstMatch(text);
    if (jsonMatch != null) return jsonMatch.group(0);

    return null;
  }

  ListingData _applyAIResult(
    ListingData listing,
    Map<String, dynamic> aiData,
    MarketplaceTemplate template,
  ) {
    final title = aiData['title']?.toString().trim() ?? listing.title;
    final description = aiData['description']?.toString().trim() ?? listing.description;

    List<String> bulletPoints = listing.bulletPoints;
    if (aiData['bulletPoints'] is List) {
      bulletPoints = (aiData['bulletPoints'] as List).map((e) => e.toString()).toList();
    } else if (aiData['highlights'] is List) {
      bulletPoints = (aiData['highlights'] as List).map((e) => e.toString()).toList();
    }

    List<String> keywords = listing.keywords;
    if (aiData['keywords'] is List) {
      keywords = (aiData['keywords'] as List).map((e) => e.toString()).toList();
    }

    String category = listing.category;
    if (aiData['category'] != null && aiData['category'].toString().isNotEmpty) {
      category = aiData['category'].toString();
    }

    return listing.copyWith(
      title: title,
      description: description,
      bulletPoints: bulletPoints,
      keywords: keywords,
      category: category,
    );
  }

  Future<File?> exportToExcel(
    List<ListingData> listings,
    String marketplaceName,
  ) async {
    if (listings.isEmpty) return null;

    final excel = Excel.createExcel();
    final safeName = marketplaceName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    final sheet = excel[safeName];
    excel.setDefaultSheet(safeName);

    final headers = listings.first.toExportRow().keys.toList();

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#4A2518'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );

    for (var col = 0; col < headers.length; col++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
      cell.value = TextCellValue(headers[col]);
      cell.cellStyle = headerStyle;
    }

    for (var row = 0; row < listings.length; row++) {
      final values = listings[row].toExportRow().values.toList();
      for (var col = 0; col < values.length; col++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1))
            .value = TextCellValue(values[col]);
      }
    }

    for (var col = 0; col < headers.length; col++) {
      sheet.setColumnWidth(col, 20);
    }

    final bytes = excel.encode();
    if (bytes == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final exportsDir = Directory('${dir.path}/exports');
    if (!await exportsDir.exists()) {
      await exportsDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'HastKala_${safeName}_Listing_$timestamp.xlsx';
    final file = File('${exportsDir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);

    return file;
  }

  Future<File?> exportAllToExcel(List<MarketplaceProduct> products) async {
    if (products.isEmpty) return null;

    final template = MarketplaceTemplate.templates.last;
    final listings = products.map((p) => mapProductToMarketplace(p, template)).toList();

    return exportToExcel(listings, 'All_Products');
  }
}
