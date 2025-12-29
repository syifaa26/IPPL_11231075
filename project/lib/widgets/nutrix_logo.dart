import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NutrixLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const NutrixLogo({super.key, this.size = 60, this.showText = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(size * 0.22),
          ),
          child: Stack(
            children: [
              // White circle background
              Center(
                child: Container(
                  width: size * 0.75,
                  height: size * 0.75,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // N letter with horizontal line
              Center(
                child: SizedBox(
                  width: size * 0.5,
                  height: size * 0.5,
                  child: CustomPaint(
                    painter: NutrixLogoPainter(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.15),
          Text(
            'NUTRIX',
            style: TextStyle(
              fontSize: size * 0.35,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 2,
            ),
          ),
        ],
      ],
    );
  }
}

class NutrixLogoPainter extends CustomPainter {
  final Color color;

  NutrixLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final strokeWidth = size.width * 0.12;
    final nWidth = size.width * 0.85;
    final nHeight = size.height * 0.7;

    // Calculate N letter positions
    final leftX = (size.width - nWidth) / 2;
    final rightX = leftX + nWidth;
    final topY = (size.height - nHeight) / 2;
    final bottomY = topY + nHeight;

    // Left vertical bar of N
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(leftX, topY, strokeWidth, nHeight),
        Radius.circular(strokeWidth / 2),
      ),
      paint,
    );

    // Right vertical bar of N
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rightX - strokeWidth, topY, strokeWidth, nHeight),
        Radius.circular(strokeWidth / 2),
      ),
      paint,
    );

    // Diagonal connecting bar (from top-left to bottom-right)
    final path = Path();
    path.moveTo(leftX + strokeWidth, topY);
    path.lineTo(rightX - strokeWidth, bottomY);
    path.lineTo(rightX, bottomY - strokeWidth * 0.5);
    path.lineTo(leftX + strokeWidth * 2, topY);
    path.close();
    canvas.drawPath(path, paint);

    // Horizontal line through middle
    final lineY = size.height / 2;
    final lineStartX = 0.0;
    final lineEndX = size.width;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          lineStartX,
          lineY - strokeWidth / 3,
          lineEndX,
          strokeWidth * 0.6,
        ),
        Radius.circular(strokeWidth / 3),
      ),
      paint,
    );

    // Small dot at bottom
    final dotRadius = strokeWidth * 0.4;
    final dotY = bottomY + strokeWidth * 0.8;
    canvas.drawCircle(Offset(size.width / 2, dotY), dotRadius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
