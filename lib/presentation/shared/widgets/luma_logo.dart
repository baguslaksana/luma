import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

enum LumaLogoSize {
  small,
  medium,
  large,
}

class LumaLogo extends StatelessWidget {
  final LumaLogoSize size;
  final Color? textColor;
  final bool showText;

  const LumaLogo({
    super.key,
    this.size = LumaLogoSize.medium,
    this.textColor,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final double iconSize;
    final double fontSize;
    final double spacing;

    switch (size) {
      case LumaLogoSize.small:
        iconSize = 28;
        fontSize = 22;
        spacing = 8;
        break;
      case LumaLogoSize.medium:
        iconSize = 40;
        fontSize = 30;
        spacing = 10;
        break;
      case LumaLogoSize.large:
        iconSize = 64;
        fontSize = 46;
        spacing = 14;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: iconSize,
          height: iconSize,
          child: CustomPaint(
            painter: _LumaRadiantIconPainter(),
          ),
        ),
        if (showText) ...[
          SizedBox(width: spacing),
          Text(
            'luma',
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.0,
              height: 1.0,
              color: textColor ?? AppTheme.heading,
            ),
          ),
        ],
      ],
    );
  }
}

/// Custom painter for Luma: A modern, curved "L" accompanied by a radiant 4-point spark of light (Luma = light/intellect)
class _LumaRadiantIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Draw modern curved "L" with Primary Blue & Secondary Blue gradient
    final lGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomRight,
      colors: [
        AppTheme.secondary, // #3B82F6 (Vibrant Blue)
        AppTheme.primary,   // #1D4ED8 (Rich Royal Blue)
      ],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final lPaint = Paint()
      ..shader = lGradient
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.19
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final lPath = Path();
    // Start at top of "L"
    lPath.moveTo(w * 0.24, h * 0.18);
    // Down stem of "L"
    lPath.lineTo(w * 0.24, h * 0.68);
    // Smooth rounded corner
    lPath.quadraticBezierTo(w * 0.24, h * 0.84, w * 0.44, h * 0.84);
    // Base foot of "L"
    lPath.lineTo(w * 0.76, h * 0.84);

    canvas.drawPath(lPath, lPaint);

    // 2. Draw 4-point Radiant Spark (symbolizing "Luma" / illumination of knowledge)
    final sparkCenter = Offset(w * 0.64, h * 0.34);
    final sparkRadius = w * 0.22;

    final sparkGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF60A5FA),  // Soft light blue glow
        AppTheme.primary,   // #1D4ED8
      ],
    ).createShader(Rect.fromCircle(center: sparkCenter, radius: sparkRadius));

    final sparkPaint = Paint()
      ..shader = sparkGradient
      ..style = PaintingStyle.fill;

    final cx = sparkCenter.dx;
    final cy = sparkCenter.dy;
    final r = sparkRadius;

    final sparkPath = Path();
    sparkPath.moveTo(cx, cy - r);
    sparkPath.quadraticBezierTo(cx, cy, cx + r, cy);
    sparkPath.quadraticBezierTo(cx, cy, cx, cy + r);
    sparkPath.quadraticBezierTo(cx, cy, cx - r, cy);
    sparkPath.quadraticBezierTo(cx, cy, cx, cy - r);
    sparkPath.close();

    canvas.drawPath(sparkPath, sparkPaint);

    // 3. Tiny radiant satellite twinkle to add refined depth
    final twinkleCenter = Offset(w * 0.84, h * 0.16);
    final twinkleRadius = w * 0.055;
    final twinklePath = Path();
    final tx = twinkleCenter.dx;
    final ty = twinkleCenter.dy;
    final tr = twinkleRadius;

    twinklePath.moveTo(tx, ty - tr);
    twinklePath.quadraticBezierTo(tx, ty, tx + tr, ty);
    twinklePath.quadraticBezierTo(tx, ty, tx, ty + tr);
    twinklePath.quadraticBezierTo(tx, ty, tx - tr, ty);
    twinklePath.quadraticBezierTo(tx, ty, tx, ty - tr);
    twinklePath.close();

    final twinklePaint = Paint()
      ..color = AppTheme.secondary
      ..style = PaintingStyle.fill;

    canvas.drawPath(twinklePath, twinklePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
