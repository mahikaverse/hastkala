import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../constants/demo_images.dart';
import '../services/api_config.dart';

class AdaptiveProductImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final String? category;

  const AdaptiveProductImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.category,
  });

  Widget _network(String url) {
    return Image.network(
      url,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) => _fallbackOrPlaceholder(),
    );
  }

  Widget _fallbackOrPlaceholder() {
    // Never show a blank box: custom placeholder if provided, else Unsplash.
    if (placeholder != null) return placeholder!;
    return Image.network(
      unsplashFallbackUrl(seed: imageUrl ?? 'hastkala', category: category),
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        color: AppColors.warmBeige,
        child: const Center(
          child: Icon(Icons.image_outlined, color: AppColors.textSecondary, size: 28),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      // Empty image -> Unsplash fallback (never blank).
      return _fallbackOrPlaceholder();
    }

    final raw = imageUrl!.trim();
    final resolved = ApiConfig.resolveImageUrl(raw);

    // 1. Check if base64 data
    if (resolved.startsWith('data:image') ||
        (!resolved.startsWith('http') && !resolved.startsWith('assets/') && resolved.length > 100 && !resolved.contains('/'))) {
      try {
        final b64 = resolved.contains(',') ? resolved.split(',').last : resolved;
        return Image.memory(
          base64Decode(b64),
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, __, ___) => _fallbackOrPlaceholder(),
        );
      } catch (_) {}
    }

    // 2. HTTP / HTTPS Network image
    if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
      return _network(resolved);
    }

    // 3. Local file
    try {
      final file = File(resolved);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, __, ___) => _fallbackOrPlaceholder(),
        );
      }
    } catch (_) {}

    // 4. Asset image fallback
    return Image.asset(
      resolved,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) => _fallbackOrPlaceholder(),
    );
  }
}
