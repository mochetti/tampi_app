import 'package:flutter/material.dart';
import 'dart:math';

class LogoPainter extends CustomPainter {
  Paint _paint;
  double _fraction, width, height;

  LogoPainter(this._fraction, this.width, this.height) {
    _paint = Paint()
      ..color = Color(0xffaecbf7)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 9;
  }
  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(width / 2, height / 2);
    canvas.scale(_fraction, _fraction);
    canvas.rotate(_fraction * 2 * pi);
    // // T superior
    var path = Path();
    path.moveTo(-width / 4, -7 * width / 20);
    path.lineTo(width / 4, -7 * width / 20);
    Rect r = Rect.fromCenter(
        center: Offset(width / 4, -width / 4),
        width: width / 5,
        height: width / 5);
    path.arcTo(r, -3.1415926 / 2, 3.1415926, false);
    path.lineTo(-width / 4, -3 * width / 20);
    r = Rect.fromCenter(
        center: Offset(-width / 4, -width / 4),
        width: width / 5,
        height: width / 5);
    path.arcTo(r, pi / 2, pi, false);
    _paint.color = Color(0xff46B1C9);
    _paint.style = PaintingStyle.fill;
    canvas.drawPath(path, _paint);

    // Círculo superior
    _paint.color = Color(0xffCE8147);
    var topCircle = Offset(0, 0);
    _paint.style = PaintingStyle.fill;
    canvas.drawCircle(topCircle, width / 10, _paint);

    // Círculo inferior
    _paint.color = Color(0xffECDD7B);
    var bottomCircle = Offset(0, width / 4);
    _paint.style = PaintingStyle.fill;
    canvas.drawCircle(bottomCircle, width / 10, _paint);
  }

  @override
  bool shouldRepaint(LogoPainter oldDelegate) {
    return oldDelegate._fraction != _fraction;
  }
}
