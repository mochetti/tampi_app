import 'package:flutter/material.dart';
import 'dart:math';

class TrajetoPage extends StatefulWidget {
  @override
  _TrajetoPageState createState() => _TrajetoPageState();
}

class _TrajetoPageState extends State<TrajetoPage>
    with SingleTickerProviderStateMixin {
  double _fraction = 0.0;
  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    animation = Tween(begin: 0.0, end: 1.0).animate(controller)
      ..addListener(() {
        setState(() {
          _fraction = animation.value;
        });
      });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trajeto')),
      body: CustomPaint(
        painter: TrajetoPainter(_fraction, MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height),
      ),
    );
  }
}

class TrajetoPainter extends CustomPainter {
  Paint _paint;
  double _fraction, width, height;

  TrajetoPainter(this._fraction, this.width, this.height) {
    _paint = Paint()
      ..color = Color(0xffaecbf7)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 9;
  }
  @override
  void paint(Canvas canvas, Size size) {
    // T superior
    var path = Path();
    path.moveTo(width / 4, height / 2 - 7 * width / 20);
    path.lineTo(3 * width / 4, height / 2 - 7 * width / 20);
    Rect r = Rect.fromCenter(
        center: Offset(3 * width / 4, height / 2 - width / 4),
        width: width / 5,
        height: width / 5);
    path.arcTo(r, -3.1415926 / 2, 3.1415926, false);
    path.lineTo(width / 4, height / 2 - 3 * width / 20);
    r = Rect.fromCenter(
        center: Offset(width / 4, height / 2 - width / 4),
        width: width / 5,
        height: width / 5);
    path.arcTo(r, pi / 2, pi, false);
    _paint.color = Color(0xff46B1C9);
    _paint.style = PaintingStyle.fill;
    canvas.drawPath(path, _paint);

    // Círculo superior
    _paint.color = Color(0xffCE8147);
    var topCircle = Offset(_fraction * width / 2, height / 2);
    _paint.style = PaintingStyle.fill;
    canvas.drawCircle(topCircle, width / 10, _paint);

    // Círculo inferior
    _paint.color = Color(0xffECDD7B);
    var bottomCircle =
        Offset(width - _fraction * width / 2, height / 2 + width / 4);
    _paint.style = PaintingStyle.fill;
    canvas.drawCircle(bottomCircle, width / 10, _paint);
  }

  @override
  bool shouldRepaint(TrajetoPainter oldDelegate) {
    return oldDelegate._fraction != _fraction;
  }
}
