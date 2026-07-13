import 'dart:math';
import 'package:flutter/material.dart';

/// رسم المحاصيل برمجياً (Vector Art) — مراحل نمو حقيقية + تمايل ريح.
/// كل دالة ترسم داخل صندوق [s] والقاعدة عند أسفل الصندوق.
class CropArt {
  static void paint(Canvas c, String id, Size s, double stage, bool ready,
      double sway) {
    switch (id) {
      case 'wheat':
        _wheat(c, s, stage, ready, sway);
      case 'corn':
        _corn(c, s, stage, ready, sway);
      case 'carrot':
        _carrot(c, s, stage, ready, sway);
      case 'tomato':
        _tomato(c, s, stage, ready, sway);
      case 'cane':
        _cane(c, s, stage, ready, sway);
    }
  }

  static void _wheat(Canvas c, Size s, double st, bool ready, double t) {
    final h = s.height * (0.30 + 0.70 * st);
    final green = Color.lerp(const Color(0xFF7CB74A), const Color(0xFFD9A93B),
        ready ? 1 : (st - 0.6).clamp(0, 1) / 0.4)!;
    final stalk = Paint()
      ..color = green
      ..strokeWidth = s.width * 0.045
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 5; i++) {
      final x = s.width * (0.15 + i * 0.175);
      final bend = sin(t * 2.2 + i) * s.width * 0.045;
      final p = Path()
        ..moveTo(x, s.height)
        ..quadraticBezierTo(
            x + bend * .4, s.height - h * .55, x + bend, s.height - h);
      c.drawPath(p, stalk);
      if (st > 0.55) {
        // سنبلة
        final head = Paint()..color = ready ? const Color(0xFFE8B84B) : green;
        for (var j = 0; j < 4; j++) {
          c.drawOval(
              Rect.fromCenter(
                  center: Offset(x + bend, s.height - h + j * s.height * .05),
                  width: s.width * .075,
                  height: s.height * .07),
              head);
        }
      }
    }
  }

  static void _corn(Canvas c, Size s, double st, bool ready, double t) {
    final h = s.height * (0.25 + 0.75 * st);
    final cx = s.width / 2 + sin(t * 2) * s.width * 0.03;
    final stalk = Paint()
      ..color = const Color(0xFF5E9E3E)
      ..strokeWidth = s.width * 0.09
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    c.drawLine(Offset(s.width / 2, s.height), Offset(cx, s.height - h), stalk);
    // أوراق منحنية
    final leaf = Paint()
      ..color = const Color(0xFF6FB44A)
      ..strokeWidth = s.width * 0.055
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    if (st > 0.3) {
      c.drawPath(
          Path()
            ..moveTo(s.width / 2, s.height - h * .35)
            ..quadraticBezierTo(s.width * .12, s.height - h * .5,
                s.width * .06, s.height - h * .78),
          leaf);
      c.drawPath(
          Path()
            ..moveTo(s.width / 2, s.height - h * .55)
            ..quadraticBezierTo(s.width * .88, s.height - h * .7,
                s.width * .94, s.height - h * .95),
          leaf);
    }
    if (st > 0.7) {
      // كوز الذرة
      final cob = Rect.fromCenter(
          center: Offset(cx + s.width * .13, s.height - h * .62),
          width: s.width * .18,
          height: s.height * .26);
      c.drawOval(cob, Paint()..color = const Color(0xFFF2C744));
      c.drawOval(
          cob,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..color = const Color(0xFF6FB44A));
    }
  }

  static void _carrot(Canvas c, Size s, double st, bool ready, double t) {
    final h = s.height * (0.22 + 0.55 * st);
    final leaf = Paint()
      ..color = const Color(0xFF4E9E3E)
      ..strokeWidth = s.width * 0.04
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (var i = -2; i <= 2; i++) {
      final ang = i * 0.32 + sin(t * 2.4) * 0.06;
      c.drawLine(
          Offset(s.width / 2, s.height),
          Offset(s.width / 2 + sin(ang) * h, s.height - cos(ang) * h),
          leaf);
    }
    if (ready) {
      // رأس الجزرة يطل من التربة
      final root = Path()
        ..moveTo(s.width * .40, s.height * .96)
        ..quadraticBezierTo(
            s.width / 2, s.height * 1.16, s.width * .60, s.height * .96)
        ..close();
      c.drawPath(root, Paint()..color = const Color(0xFFE8762C));
    }
  }

  static void _tomato(Canvas c, Size s, double st, bool ready, double t) {
    final h = s.height * (0.30 + 0.65 * st);
    final bush = Paint()..color = const Color(0xFF4E8F35);
    final bush2 = Paint()..color = const Color(0xFF5FA83F);
    final sway = sin(t * 2) * s.width * 0.02;
    c.drawCircle(
        Offset(s.width * .38 + sway, s.height - h * .45), h * .34, bush);
    c.drawCircle(
        Offset(s.width * .62 + sway, s.height - h * .48), h * .36, bush);
    c.drawCircle(
        Offset(s.width * .5 + sway, s.height - h * .72), h * .32, bush2);
    if (st > 0.75 || ready) {
      final fruit = Paint()
        ..color = ready ? const Color(0xFFE04B3A) : const Color(0xFFE8952C);
      c.drawCircle(Offset(s.width * .40 + sway, s.height - h * .40),
          s.width * .085, fruit);
      c.drawCircle(Offset(s.width * .64 + sway, s.height - h * .55),
          s.width * .085, fruit);
      c.drawCircle(Offset(s.width * .52 + sway, s.height - h * .28),
          s.width * .085, fruit);
    }
  }

  static void _cane(Canvas c, Size s, double st, bool ready, double t) {
    final h = s.height * (0.30 + 0.70 * st);
    final stalk = Paint()
      ..color = ready ? const Color(0xFFB9C24E) : const Color(0xFF8FB84A)
      ..strokeWidth = s.width * 0.07
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final seg = Paint()
      ..color = const Color(0xFF6E8F35)
      ..strokeWidth = 1.6;
    for (var i = 0; i < 3; i++) {
      final x = s.width * (0.28 + i * 0.22);
      final bend = sin(t * 2 + i * 1.4) * s.width * 0.04;
      c.drawLine(Offset(x, s.height), Offset(x + bend, s.height - h), stalk);
      for (var j = 1; j < 4; j++) {
        final y = s.height - h * j / 4;
        c.drawLine(Offset(x - s.width * .045 + bend * j / 4, y),
            Offset(x + s.width * .045 + bend * j / 4, y), seg);
      }
    }
  }
}
