import 'package:flutter/material.dart';

class MarketplaceTemplate {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;
  final List<String> requiredFields;
  final int maxProducts;
  final String aiSystemPrompt;

  const MarketplaceTemplate({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    required this.requiredFields,
    this.maxProducts = 50,
    required this.aiSystemPrompt,
  });

  static const List<MarketplaceTemplate> templates = [
    MarketplaceTemplate(
      id: 'amazon',
      name: 'Amazon',
      icon: Icons.shopping_cart_rounded,
      color: Color(0xFFFF9900),
      description: 'Create product listings with bullet points, search terms, and detailed descriptions for Amazon Seller Central.',
      requiredFields: ['title', 'description', 'bulletPoints', 'keywords', 'category', 'material', 'price'],
      maxProducts: 50,
      aiSystemPrompt: '''You are an Amazon product listing expert. Given a handcrafted Indian product, generate:
1. An optimized product title (max 200 chars, include key attributes)
2. Five bullet points highlighting features, material, craft, and use cases
3. A product description (2-3 paragraphs, compelling and factual)
4. Seven search keywords (relevant to Indian handcrafted products)

Rules:
- NEVER invent material, dimensions, certifications, or origin claims
- NEVER change the price
- Keep factual accuracy — only format and enhance existing information
- Use natural, compelling Amazon-style copy
- Mention "handmade" and "artisan" where appropriate
- Return JSON with keys: title, bulletPoints (list), description, keywords (list)''',
    ),
    MarketplaceTemplate(
      id: 'flipkart',
      name: 'Flipkart',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFF2874F0),
      description: 'Prepare listings with highlights, specifications, and SEO-friendly descriptions for Flipkart Seller Hub.',
      requiredFields: ['title', 'description', 'keywords', 'category', 'material', 'price'],
      maxProducts: 30,
      aiSystemPrompt: '''You are a Flipkart product listing expert. Given a handcrafted Indian product, generate:
1. An SEO-friendly product name (max 150 chars)
2. A compelling product description (2-3 paragraphs)
3. 3-5 product highlights (short, punchy points)
4. Five search keywords

Rules:
- NEVER invent material, dimensions, certifications, or origin claims
- NEVER change the price
- Keep factual accuracy — only format and enhance existing information
- Use Flipkart-style listing format
- Return JSON with keys: title, description, highlights (list), keywords (list)''',
    ),
    MarketplaceTemplate(
      id: 'blinkit',
      name: 'Blinkit',
      icon: Icons.flash_on_rounded,
      color: Color(0xFF00C853),
      description: 'Create quick-commerce style short listings optimized for Blinkit\'s discovery format.',
      requiredFields: ['title', 'description', 'category', 'material', 'price'],
      maxProducts: 20,
      aiSystemPrompt: '''You are a Blinkit product listing expert. Given a handcrafted Indian product, generate:
1. A short, catchy product name (max 60 chars)
2. A brief, punchy description (1-2 sentences max)
3. A category label (short, 2-3 words)

Rules:
- NEVER invent material, dimensions, certifications, or origin claims
- NEVER change the price
- Keep it ultra-concise — Blinkit style is minimal and quick
- Focus on what makes the product special in one line
- Return JSON with keys: title, description, category''',
    ),
    MarketplaceTemplate(
      id: 'other',
      name: 'Other Marketplaces',
      icon: Icons.storefront_rounded,
      color: Color(0xFF6B4E3D),
      description: 'Generate a universal product listing that works across multiple online marketplaces.',
      requiredFields: ['title', 'description', 'keywords', 'category', 'material', 'price'],
      maxProducts: 50,
      aiSystemPrompt: '''You are a multi-marketplace product listing expert. Given a handcrafted Indian product, generate:
1. A universal product title (clear, descriptive, max 150 chars)
2. A comprehensive product description (2-3 paragraphs)
3. Five search keywords
4. 3-5 key product highlights

Rules:
- NEVER invent material, dimensions, certifications, or origin claims
- NEVER change the price
- Keep factual accuracy — only format and enhance existing information
- Make it work across multiple platforms (Meesho, JioMart, etc.)
- Return JSON with keys: title, description, keywords (list), highlights (list)''',
    ),
  ];
}
