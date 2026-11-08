import 'dart:ui';

/// Pawdian brand mark: a white shield ("guardian") holding a teal paw.
/// Drawn in unit coordinates and scaled to [rect].
const brandTeal = Color(0xFF2E7D6B);
const brandTealDark = Color(0xFF1F5E50);

void paintShieldPaw(
  Canvas canvas,
  Rect rect, {
  Color shield = const Color(0xFFFFFFFF),
  Color paw = brandTeal,
}) {
  Offset p(double x, double y) =>
      Offset(rect.left + x * rect.width, rect.top + y * rect.height);

  final shieldPath = Path()
    ..moveTo(p(0.18, 0.22).dx, p(0.18, 0.22).dy)
    ..quadraticBezierTo(
      p(0.5, 0.08).dx,
      p(0.5, 0.08).dy,
      p(0.82, 0.22).dx,
      p(0.82, 0.22).dy,
    )
    ..lineTo(p(0.82, 0.50).dx, p(0.82, 0.50).dy)
    ..cubicTo(
      p(0.82, 0.73).dx,
      p(0.82, 0.73).dy,
      p(0.63, 0.86).dx,
      p(0.63, 0.86).dy,
      p(0.5, 0.92).dx,
      p(0.5, 0.92).dy,
    )
    ..cubicTo(
      p(0.37, 0.86).dx,
      p(0.37, 0.86).dy,
      p(0.18, 0.73).dx,
      p(0.18, 0.73).dy,
      p(0.18, 0.50).dx,
      p(0.18, 0.50).dy,
    )
    ..close();
  canvas.drawPath(
    shieldPath,
    Paint()
      ..color = shield
      ..isAntiAlias = true,
  );

  final pawPaint = Paint()
    ..color = paw
    ..isAntiAlias = true;
  Rect oval(double cx, double cy, double w, double h) => Rect.fromCenter(
    center: p(cx, cy),
    width: w * rect.width,
    height: h * rect.height,
  );
  // Toes
  canvas.drawOval(oval(0.335, 0.455, 0.095, 0.115), pawPaint);
  canvas.drawOval(oval(0.435, 0.355, 0.10, 0.125), pawPaint);
  canvas.drawOval(oval(0.565, 0.355, 0.10, 0.125), pawPaint);
  canvas.drawOval(oval(0.665, 0.455, 0.095, 0.115), pawPaint);
  // Pad
  final pad = Path()
    ..moveTo(p(0.5, 0.48).dx, p(0.5, 0.48).dy)
    ..cubicTo(
      p(0.40, 0.48).dx,
      p(0.40, 0.48).dy,
      p(0.33, 0.60).dx,
      p(0.33, 0.60).dy,
      p(0.34, 0.67).dx,
      p(0.34, 0.67).dy,
    )
    ..cubicTo(
      p(0.35, 0.74).dx,
      p(0.35, 0.74).dy,
      p(0.43, 0.74).dx,
      p(0.43, 0.74).dy,
      p(0.5, 0.71).dx,
      p(0.5, 0.71).dy,
    )
    ..cubicTo(
      p(0.57, 0.74).dx,
      p(0.57, 0.74).dy,
      p(0.65, 0.74).dx,
      p(0.65, 0.74).dy,
      p(0.66, 0.67).dx,
      p(0.66, 0.67).dy,
    )
    ..cubicTo(
      p(0.67, 0.60).dx,
      p(0.67, 0.60).dy,
      p(0.60, 0.48).dx,
      p(0.60, 0.48).dy,
      p(0.5, 0.48).dx,
      p(0.5, 0.48).dy,
    )
    ..close();
  canvas.drawPath(pad, pawPaint);
}
