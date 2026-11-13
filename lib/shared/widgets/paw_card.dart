import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

/// Rounded card with a warm shadow, used for most grouped content.
class PawCard extends StatelessWidget {
  const PawCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    this.color,
    this.radius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? color;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final p = context.paw;
    final r = BorderRadius.circular(radius ?? PawRadius.card);
    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: softCard(p, color: color, radius: radius),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: r,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

/// Section heading above a group of cards, with an optional action.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing, this.color});

  final String text;
  final Widget? trailing;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.paw;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color ?? p.ink,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Icon on a soft tone background (rounded square).
class ToneIcon extends StatelessWidget {
  const ToneIcon({
    super.key,
    required this.icon,
    required this.tone,
    this.size = 40,
  });

  final IconData icon;
  final Tone tone;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: tone.bg,
      borderRadius: BorderRadius.circular(size * 0.34),
    ),
    alignment: Alignment.center,
    child: Icon(icon, size: size * 0.52, color: tone.fg),
  );
}

/// Round "done" button with haptic feedback.
class DoneButton extends StatelessWidget {
  const DoneButton({
    super.key,
    required this.onPressed,
    required this.tooltip,
    this.highlighted = false,
  });

  final VoidCallback onPressed;
  final String tooltip;

  /// Filled when the task is due; outlined otherwise.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final p = context.paw;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: highlighted ? p.brand : p.brandSoft,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            HapticFeedback.mediumImpact();
            onPressed();
          },
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              Icons.check_rounded,
              size: 22,
              color: highlighted ? p.onBrand : p.brand,
            ),
          ),
        ),
      ),
    );
  }
}

/// Small rounded label, e.g. "Tomorrow 09:00".
class PawPill extends StatelessWidget {
  const PawPill(
    this.text, {
    super.key,
    required this.bg,
    required this.fg,
    this.icon,
  });

  final String text;
  final Color bg;
  final Color fg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
        ],
        Text(
          text,
          style: TextStyle(
            color: fg,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
