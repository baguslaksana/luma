import 'package:flutter/material.dart';

class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({
    super.key,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final strokeWidth = w * 0.21;
    final radius = (w - strokeWidth) / 2;
    final center = Offset(w / 2, h / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // 1. Red (Top Arc)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -3.14159 * 0.75, 3.14159 * 0.52, false, paint);

    // 2. Yellow (Left Arc)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, -3.14159 * 1.28, 3.14159 * 0.54, false, paint);

    // 3. Green (Bottom Arc)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 3.14159 * 0.25, 3.14159 * 0.53, false, paint);

    // 4. Blue (Right Arc)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -3.14159 * 0.22, 3.14159 * 0.47, false, paint);

    // 5. Blue (Horizontal cross bar)
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.44, h * 0.40, w * 0.54, strokeWidth * 0.95),
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
