import 'package:flutter/material.dart';

/// A reusable global background container for the HastKala app.
///
/// Displays the default handcrafted Indian cream background with
/// mandala and botanical decorations. Use this on all basic/auth
/// screens that don't have their own custom artwork.
class HastKalaBackground extends StatelessWidget {
  const HastKalaBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/default-bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: child,
      ),
    );
  }
}
