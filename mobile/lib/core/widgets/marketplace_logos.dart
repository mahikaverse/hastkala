import 'package:flutter/material.dart';

class MarketplaceLogos {
  MarketplaceLogos._();

  static Widget amazon({double size = 48}) {
    return Image.asset(
      'assets/amazon-logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _fallback('amazon', size),
    );
  }

  static Widget flipkart({double size = 48}) {
    return Image.asset(
      'assets/flipkart-logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _fallback('flipkart', size),
    );
  }

  static Widget blinkit({double size = 48}) {
    return Image.asset(
      'assets/blinkit-logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _fallback('blinkit', size),
    );
  }

  static Widget other({double size = 48}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF6B4E3D),
        borderRadius: BorderRadius.circular(size * 0.18),
      ),
      child: Icon(
        Icons.storefront_rounded,
        size: size * 0.5,
        color: Colors.white,
      ),
    );
  }

  static Widget _fallback(String id, double size) {
    switch (id) {
      case 'amazon':
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFF232F3E),
            borderRadius: BorderRadius.circular(size * 0.18),
          ),
          child: Center(
            child: Text(
              'a',
              style: TextStyle(
                fontSize: size * 0.55,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFF9900),
              ),
            ),
          ),
        );
      case 'flipkart':
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFF2874F0),
            borderRadius: BorderRadius.circular(size * 0.18),
          ),
          child: Center(
            child: Text(
              'F',
              style: TextStyle(
                fontSize: size * 0.5,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
      case 'blinkit':
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFF00C853),
            borderRadius: BorderRadius.circular(size * 0.18),
          ),
          child: Icon(Icons.bolt_rounded, size: size * 0.5, color: Colors.white),
        );
      default:
        return other(size: size);
    }
  }

  static Widget forId(String id, {double size = 48}) {
    switch (id) {
      case 'amazon':
        return amazon(size: size);
      case 'flipkart':
        return flipkart(size: size);
      case 'blinkit':
        return blinkit(size: size);
      default:
        return other(size: size);
    }
  }
}
