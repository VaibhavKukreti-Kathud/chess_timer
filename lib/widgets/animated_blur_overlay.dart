import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A reusable overlay that provides a blurred, dimmed background
/// with fade in/out animations. Matches the behavior used in the
/// pause-state overlay for consistency across screens.
class AnimatedBlurOverlay extends StatelessWidget {
  final bool isVisible;
  final Widget child;
  final VoidCallback? onTap;
  final double blurSigma;
  final Duration duration;
  final Curve curve;
  final Color backgroundColor;

  const AnimatedBlurOverlay({
    super.key,
    required this.isVisible,
    required this.child,
    this.onTap,
    this.blurSigma = 5.0,
    this.duration = AppDurations.medium,
    this.curve = Curves.easeOutCirc,
    this.backgroundColor = AppColors.overlayScrim, // ~black 80%
  });

  @override
  Widget build(BuildContext context) {
    // Clip the area to avoid blurring offscreen content (perf)
    return IgnorePointer(
      ignoring: !isVisible,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: isVisible ? blurSigma : 0.0,
              sigmaY: isVisible ? blurSigma : 0.0,
            ),
            child: AnimatedContainer(
              duration: duration,
              curve: curve,
              decoration: BoxDecoration(
                color: isVisible ? backgroundColor : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadii.bg),
              ),
              child: AnimatedOpacity(
                duration: duration,
                curve: curve,
                opacity: isVisible ? 1.0 : 0.0,
                // Isolate child's paints to reduce repaint scope
                child: RepaintBoundary(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
