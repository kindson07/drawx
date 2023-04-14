import 'package:flutter/material.dart';
import 'dart:math';

class WheelOfFortune extends StatefulWidget {
  final List<String> items;
  final List<double> probabilities;

  const WheelOfFortune({Key? key, required this.items, required this.probabilities}) : super(key: key);

  @override
  _WheelOfFortuneState  createState() => _WheelOfFortuneState();
}

class _WheelOfFortuneState extends State<WheelOfFortune> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _spinAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _animation.addListener(() {
      setState(() {
        _spinAngle = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spinWheel() {
    _controller.stop();
    _controller.value = 0.0;
    final random = Random();
    final targetIndex = _selectItemBasedOnProbability();
    final targetAngle = _calculateTargetAngle(targetIndex);
    _animation = Tween<double>(begin: _spinAngle, end: _spinAngle + 2 * pi * 5 + targetAngle)
        .animate(_controller);
    _controller.forward();
  }

  int _selectItemBasedOnProbability() {
    final totalProbability = widget.probabilities.reduce((a, b) => a + b);
    final randomValue = Random().nextDouble() * totalProbability;
    double sum = 0;
    for (int i = 0; i < widget.probabilities.length; i++) {
    sum += widget.probabilities[i];
    if (randomValue <= sum) {
    return i;
    }
    }
    return 0;
    }

  double _calculateTargetAngle(int targetIndex) {
    final angles = _calculateAngles();
    double sum = 0;
    for (int i = 0; i < targetIndex; i++) {
    sum += angles[i];
    }
    final double startAngle = sum;
    final double endAngle = sum + angles[targetIndex];
    return Random().nextDouble() * (endAngle - startAngle) + startAngle;
    }

  List<double> _calculateAngles() {
    final totalProbability = widget.probabilities.reduce((a, b) => a + b);
    return widget.probabilities.map((prob) => 2 * pi * (prob / totalProbability)).toList();
  }

@override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform.rotate(
          angle: _spinAngle,
          child: _buildWheel(),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: FloatingActionButton(
              onPressed: _spinWheel,
              child: const Icon(Icons.ads_click_outlined),
            ),
          ),
        ),
        _buildPointer(),
      ],
    );

  }

  Widget _buildWheel() {
    return CustomPaint(
      size: Size.square(300),
      painter: _WheelPainter(items: widget.items),
    );
  }
}

// add _buildPointer methods
Widget _buildPointer() {
  return Positioned(
    top: 0,
    left: 0,
    right: 0,
    child: Container(
      height: 40,
      child: CustomPaint(
        painter: TrianglePainter(color: Colors.white), // use the new TrianglePainter class
      ),
    ),
  );
}

class _WheelPainter extends CustomPainter {
  final List<String> items;

  _WheelPainter({required this.items});

  @override
  void paint(Canvas canvas, Size size) {
    final double itemAngle = 2 * pi / items.length;
    final double radius = min(size.width, size.height) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < items.length; i++) {
      final double startAngle = i * itemAngle;
      final double sweepAngle = itemAngle;

      final Paint paint = Paint()
        ..color = Colors.accents[i % Colors.accents.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      final double textAngle = startAngle + sweepAngle / 2;
      final Offset textOffset = Offset(
        center.dx + radius * cos(textAngle) / 2,
        center.dy + radius * sin(textAngle) / 2,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: items[i],
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout(minWidth: 0, maxWidth: size.width);
      textPainter.paint(canvas,
          textOffset - Offset(textPainter.width / 2, textPainter.height / 2));
    }

    //add the center point
    final Paint circlePaint = Paint()
      ..color = Colors.white // setting the center point color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 4.0, circlePaint); // setting the center radius
  }
    @override
    bool shouldRepaint(CustomPainter oldDelegate) {
      return true;
    }
  }
// add TrianglePainter class
class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Paint strokePaint = Paint()
      ..color = Colors.grey // setting the color of edge
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0; // setting the width of edge

    final path = Path();
    path.moveTo(size.width / 2- 15,  0);
    path.lineTo(size.width / 2 + 15, 0);
    path.lineTo(size.width / 2 , size.height);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint); //draw the edge
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}