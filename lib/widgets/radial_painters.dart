// Copyright 2023 Bruce Eleniak. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

/// @nodoc
class RadialLine extends StatelessWidget {
  final Offset center;
  final double startRadius;
  final double endRadius;
  final double rotationRadians;
  final double width;
  final Color color;
  const RadialLine({
    super.key,
    required this.center,
    required this.startRadius,
    required this.endRadius,
    required this.rotationRadians,
    required this.width,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: RadialLinePainter(
        center: center,
        startRadius: startRadius,
        endRadius: endRadius,
        rotationRadians: rotationRadians,
        width: width,
        color: color,
      ),
    );
  }
}

/// @nodoc
class RadialLinePainter extends CustomPainter {
  final Offset center;
  final double startRadius;
  final double endRadius;
  final double rotationRadians;
  final double width;
  final Color color;

  RadialLinePainter({
    required this.center,
    required this.startRadius,
    required this.endRadius,
    required this.rotationRadians,
    required this.width,
    required this.color,
  });
  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationRadians);
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, startRadius), Offset(0, endRadius), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
