import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../services/api_config.dart';

class AdaptiveProductImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;

  const AdaptiveProductImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
  });

  Widget _defaultPlaceholder() {
    return placeholder ??
        Container(
          width: width,
          height: height,
          color: AppColors.warmBeige,
          child: const Center(
            child: Icon(Icons.image_outlined, color: AppColors.textSecondary, size: 28),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return _defaultPlaceholder();
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
          errorBuilder: (_, __, ___) => _defaultPlaceholder(),
        );
      } catch (_) {}
    }

    // 2. HTTP / HTTPS Network image
    if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
      return Image.network(
        resolved,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => _defaultPlaceholder(),
      );
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
          errorBuilder: (_, __, ___) => _defaultPlaceholder(),
        );
      }
    } catch (_) {}

    // 4. Asset image fallback
    return Image.asset(
      resolved,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) => _defaultPlaceholder(),
    );
  }
}
