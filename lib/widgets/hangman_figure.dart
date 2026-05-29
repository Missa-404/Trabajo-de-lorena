import 'package:flutter/material.dart';

class HangmanFigure extends StatelessWidget {
  final int errors;
  const HangmanFigure({Key? key, required this.errors}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 250,
      child: CustomPaint(
        painter: HangmanPainter(errors),
      ),
    );
  }
}

class HangmanPainter extends CustomPainter {
  final int errors;
  HangmanPainter(this.errors);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(20, size.height - 20), Offset(size.width - 20, size.height - 20), paint);
    canvas.drawLine(Offset(40, size.height - 20), Offset(40, 20), paint);
    canvas.drawLine(Offset(40, 20), Offset(size.width / 2 + 40, 20), paint);
    canvas.drawLine(Offset(size.width / 2 + 40, 20), Offset(size.width / 2 + 40, 50), paint);

    if (errors >= 1) {
      canvas.drawCircle(Offset(size.width / 2 + 40, 70), 20, paint);
    }
    if (errors >= 2) {
      canvas.drawLine(Offset(size.width / 2 + 40, 90), Offset(size.width / 2 + 40, 160), paint);
    }
    if (errors >= 3) {
      canvas.drawLine(Offset(size.width / 2 + 40, 110), Offset(size.width / 2, 140), paint);
    }
    if (errors >= 4) {
      canvas.drawLine(Offset(size.width / 2 + 40, 110), Offset(size.width / 2 + 80, 140), paint);
    }
    if (errors >= 5) {
      canvas.drawLine(Offset(size.width / 2 + 40, 160), Offset(size.width / 2, 200), paint);
    }
    if (errors >= 6) {
      canvas.drawLine(Offset(size.width / 2 + 40, 160), Offset(size.width / 2 + 80, 200), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}