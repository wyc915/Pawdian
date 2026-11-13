import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';

/// Friendly empty page: a small "paw bubble" illustration, title and text.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final p = context.paw;
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 150,
              height: 130,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(left: 6, top: 14, child: _dot(p.peach.bg, 30)),
                  Positioned(right: 4, top: 4, child: _dot(p.sky.bg, 22)),
                  Positioned(
                    right: 14,
                    bottom: 6,
                    child: _dot(p.butter.bg, 26),
                  ),
                  Positioned(
                    left: 18,
                    bottom: 10,
                    child: Icon(
                      Icons.pets,
                      size: 18,
                      color: p.peach.fg.withValues(alpha: 0.5),
                    ),
                  ),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: p.mint.bg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 46, color: p.mint.fg),
                  ).animate().scale(
                    begin: const Offset(0.8, 0.8),
                    duration: 450.ms,
                    curve: Curves.easeOutBack,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (body.isNotEmpty) const SizedBox(height: 8),
            if (body.isNotEmpty)
              Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(color: p.subtle),
                textAlign: TextAlign.center,
              ),
          ],
        ).animate().fadeIn(duration: 300.ms),
      ),
    );
  }

  static Widget _dot(Color c, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );
}
