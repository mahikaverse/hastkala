import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../services/tts_service.dart';

/// Reusable voice mute / unmute button that binds directly to [TtsService.isMutedNotifier].
/// When tapped, toggles the global mute state and stops speech immediately.
/// When unmuted, can optionally trigger [onReplay] to speak the current page's prompt.
class VoiceMuteButton extends StatelessWidget {
  final Color? color;
  final Color? backgroundColor;
  final VoidCallback? onReplay;

  const VoiceMuteButton({
    super.key,
    this.color,
    this.backgroundColor,
    this.onReplay,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: TtsService.isMutedNotifier,
      builder: (context, isMuted, _) {
        final iconWidget = AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: Icon(
            isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            key: ValueKey<bool>(isMuted),
            color: isMuted ? (color ?? AppColors.cream).withValues(alpha: 0.6) : (color ?? AppColors.cream),
            size: 22,
          ),
        );

        if (backgroundColor != null) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              tooltip: isMuted ? 'Unmute voice' : 'Mute voice',
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
              icon: iconWidget,
              onPressed: () {
                final willBeMuted = !TtsService.isMutedNotifier.value;
                TtsService().toggleMute();
                if (!willBeMuted && onReplay != null) {
                  onReplay!();
                }
              },
            ),
          );
        }

        return IconButton(
          tooltip: isMuted ? 'Unmute voice' : 'Mute voice',
          icon: iconWidget,
          onPressed: () {
            final willBeMuted = !TtsService.isMutedNotifier.value;
            TtsService().toggleMute();
            if (!willBeMuted && onReplay != null) {
              onReplay!();
            }
          },
        );
      },
    );
  }
}
