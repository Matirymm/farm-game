import 'dart:math';
import 'package:flutter/material.dart';

/// رسم الحيوانات برمجياً — دورة مشي (أرجل متناوبة) واتجاه يمين افتراضي.
class AnimalArt {
  static void paint(
      Canvas c, String type, Size s, double phase, bool walking) {
    switch (type) {
      case 'chicken':
        _chicken(c, s, phase, walking);
      case 'cow':
        _cow(c, s, phase, walking);
      case 'sheep':
        _sheep(c, s, phase, walking);
    }
  }

  static double _legSwing(double phase, bool walking, double amp) =>
      walking ? sin(phase) * amp : 0;

  static void _chicken(Canvas c, Size s, double ph, bool walk) {
    final legPaint = Paint()
      ..color = const Color(0xFFE8952C)
      ..strokeWidth = s.width * .045
      ..strokeCap = StrokeCap.round;
    final sw = _legSwing(ph, walk, s.width * .07);
    c.drawLine(Offset(s.width * .42, s.height * .74),
        Offset(s.width * .40 + sw, s.height * .98), legPaint);
    c.drawLine(Offset(s.width * .56, s.height * .74),
        Offset(s.width * .58 - sw, s.height * .98), legPaint);
    // الجسم
    final body = Rect.fromCenter(
        center: Offset(s.width * .48, s.height * .52),
        width: s.width * .62,
        height: s.height * .52);
    c.drawOval(body, Paint()..color = const Color(0xFFFBF6EA));
    c.drawOval(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = const Color(0xFFB8AD98));
    // ذيل
    final tail = Path()
      ..moveTo(s.width * .20, s.height * .52)
      ..lineTo(s.width * .04, s.height * .32)
      ..lineTo(s.width * .22, s.height * .40)
      ..close();
    c.drawPath(tail, Paint()..color = const Color(0xFFE8E0CE));
    // جناح
    c.drawOval(
        Rect.fromCenter(
            center: Offset(s.width * .45, s.height * .56),
            width: s.width * .30,
            height: s.height * .24),
        Paint()..color = const Color(0xFFE8E0CE));
    // الرأس
    c.drawCircle(Offset(s.width * .76, s.height * .28), s.width * .15,
        Paint()..color = const Color(0xFFFBF6EA));
    // عرف
    final comb = Paint()..color = const Color(0xFFD84B3A);
    c.drawCircle(Offset(s.width * .72, s.height * .14), s.width * .05, comb);
    c.drawCircle(Offset(s.width * .80, s.height * .12), s.width * .05, comb);
    // منقار وداليّة
    final beak = Path()
      ..moveTo(s.width * .89, s.height * .26)
      ..lineTo(s.width * 1.00, s.height * .30)
      ..lineTo(s.width * .89, s.height * .34)
      ..close();
    c.drawPath(beak, Paint()..color = const Color(0xFFE8952C));
    c.drawCircle(Offset(s.width * .87, s.height * .38), s.width * .035, comb);
    // عين
    c.drawCircle(Offset(s.width * .79, s.height * .26), s.width * .028,
        Paint()..color = const Color(0xFF3B2A18));
  }

  static void _cow(Canvas c, Size s, double ph, bool walk) {
    final leg = Paint()
      ..color = const Color(0xFF4A4038)
      ..strokeWidth = s.width * .055
      ..strokeCap = StrokeCap.round;
    final sw = _legSwing(ph, walk, s.width * .05);
    for (final e in [
      [.28, sw],
      [.40, -sw],
      [.60, sw],
      [.72, -sw]
    ]) {
      c.drawLine(Offset(s.width * (e[0] as double), s.height * .70),
          Offset(s.width * (e[0] as double) + (e[1] as double), s.height * .98),
          leg);
    }
    // الجسم
    final body = Rect.fromCenter(
        center: Offset(s.width * .48, s.height * .48),
        width: s.width * .72,
        height: s.height * .48);
    c.drawOval(body, Paint()..color = const Color(0xFFF7F3EA));
    c.drawOval(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = const Color(0xFFB0A491));
    // بقع
    final patch = Paint()..color = const Color(0xFF3E362E);
    c.drawOval(
        Rect.fromCenter(
            center: Offset(s.width * .34, s.height * .42),
            width: s.width * .22,
            height: s.height * .20),
        patch);
    c.drawOval(
        Rect.fromCenter(
            center: Offset(s.width * .58, s.height * .56),
            width: s.width * .18,
            height: s.height * .16),
        patch);
    // ذيل
    c.drawLine(
        Offset(s.width * .12, s.height * .40),
        Offset(s.width * .05, s.height * .64),
        Paint()
          ..color = const Color(0xFFB0A491)
          ..strokeWidth = s.width * .025
          ..strokeCap = StrokeCap.round);
    // الرأس
    final head = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(s.width * .84, s.height * .36),
            width: s.width * .26,
            height: s.height * .34),
        Radius.circular(s.width * .08));
    c.drawRRect(head, Paint()..color = const Color(0xFFF7F3EA));
    // خطم وردي
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(s.width * .84, s.height * .46),
                width: s.width * .22,
                height: s.height * .13),
            Radius.circular(s.width * .06)),
        Paint()..color = const Color(0xFFE8B4A8));
    // أذنان وقرنان
    c.drawOval(
        Rect.fromCenter(
            center: Offset(s.width * .72, s.height * .22),
            width: s.width * .10,
            height: s.height * .07),
        Paint()..color = const Color(0xFFE0D6C4));
    c.drawArc(
        Rect.fromCenter(
            center: Offset(s.width * .90, s.height * .18),
            width: s.width * .10,
            height: s.height * .10),
        pi,
        pi,
        false,
        Paint()
          ..color = const Color(0xFFE8DCC0)
          ..strokeWidth = s.width * .03
          ..style = PaintingStyle.stroke);
    // عين
    c.drawCircle(Offset(s.width * .82, s.height * .32), s.width * .025,
        Paint()..color = const Color(0xFF3B2A18));
  }

  static void _sheep(Canvas c, Size s, double ph, bool walk) {
    final leg = Paint()
      ..color = const Color(0xFF4A4038)
      ..strokeWidth = s.width * .05
      ..strokeCap = StrokeCap.round;
    final sw = _legSwing(ph, walk, s.width * .05);
    c.drawLine(Offset(s.width * .34, s.height * .70),
        Offset(s.width * .32 + sw, s.height * .98), leg);
    c.drawLine(Offset(s.width * .62, s.height * .70),
        Offset(s.width * .64 - sw, s.height * .98), leg);
    // صوف — عناقيد دوائر
    final wool = Paint()..color = const Color(0xFFF3EEE2);
    final woolD = Paint()..color = const Color(0xFFE4DCC9);
    c.drawCircle(Offset(s.width * .30, s.height * .50), s.width * .18, woolD);
    c.drawCircle(Offset(s.width * .62, s.height * .52), s.width * .19, woolD);
    c.drawCircle(Offset(s.width * .46, s.height * .40), s.width * .21, wool);
    c.drawCircle(Offset(s.width * .58, s.height * .38), s.width * .17, wool);
    c.drawCircle(Offset(s.width * .34, s.height * .38), s.width * .16, wool);
    c.drawCircle(Offset(s.width * .48, s.height * .56), s.width * .18, wool);
    // الوجه
    c.drawOval(
        Rect.fromCenter(
            center: Offset(s.width * .80, s.height * .42),
            width: s.width * .20,
            height: s.height * .26),
        Paint()..color = const Color(0xFF56493E));
    // أذن
    c.drawOval(
        Rect.fromCenter(
            center: Offset(s.width * .70, s.height * .32),
            width: s.width * .11,
            height: s.height * .07),
        Paint()..color = const Color(0xFF46392F));
    // عين
    c.drawCircle(Offset(s.width * .82, s.height * .38), s.width * .026,
        Paint()..color = Colors.white);
  }

  // ---------- أيقونات المنتجات والحالة (للفقاعات والقوائم) ----------
  static void paintProduct(Canvas c, String id, Size s) {
    switch (id) {
      case 'egg':
        c.drawOval(
            Rect.fromCenter(
                center: Offset(s.width / 2, s.height * .55),
                width: s.width * .62,
                height: s.height * .80),
            Paint()..color = const Color(0xFFFDF8EC));
        c.drawOval(
            Rect.fromCenter(
                center: Offset(s.width * .42, s.height * .42),
                width: s.width * .16,
                height: s.height * .22),
            Paint()..color = Colors.white);
      case 'milk':
        final b = RRect.fromRectAndRadius(
            Rect.fromLTWH(s.width * .30, s.height * .28, s.width * .40,
                s.height * .66),
            Radius.circular(s.width * .10));
        c.drawRRect(b, Paint()..color = const Color(0xFFF4F7FA));
        c.drawRect(
            Rect.fromLTWH(
                s.width * .38, s.height * .12, s.width * .24, s.height * .18),
            Paint()..color = const Color(0xFFCADEE8));
        c.drawRect(
            Rect.fromLTWH(
                s.width * .30, s.height * .58, s.width * .40, s.height * .22),
            Paint()..color = const Color(0xFF9EC8DC));
      case 'wool':
        final wool = Paint()..color = const Color(0xFFE9E2D2);
        c.drawCircle(
            Offset(s.width * .40, s.height * .50), s.width * .24, wool);
        c.drawCircle(
            Offset(s.width * .62, s.height * .46), s.width * .22, wool);
        c.drawCircle(
            Offset(s.width * .50, s.height * .64), s.width * .22, wool);
        c.drawArc(
            Rect.fromCenter(
                center: Offset(s.width * .5, s.height * .52),
                width: s.width * .34,
                height: s.height * .30),
            0,
            4.5,
            false,
            Paint()
              ..color = const Color(0xFFB8AD98)
              ..strokeWidth = 1.6
              ..style = PaintingStyle.stroke);
    }
  }

  /// أيقونة "جائع" — حزمة علف ذهبية
  static void paintFeedIcon(Canvas c, Size s) {
    final p = Paint()
      ..color = const Color(0xFFD9A93B)
      ..strokeWidth = s.width * .10
      ..strokeCap = StrokeCap.round;
    c.drawLine(Offset(s.width * .5, s.height * .95),
        Offset(s.width * .5, s.height * .15), p);
    c.drawLine(Offset(s.width * .5, s.height * .95),
        Offset(s.width * .22, s.height * .30), p);
    c.drawLine(Offset(s.width * .5, s.height * .95),
        Offset(s.width * .78, s.height * .30), p);
  }

  /// حلقة تقدم الإنتاج
  static void paintProgress(Canvas c, Size s, double pct) {
    final r = Rect.fromCenter(
        center: Offset(s.width / 2, s.height / 2),
        width: s.width * .78,
        height: s.height * .78);
    c.drawArc(
        r,
        0,
        2 * pi,
        false,
        Paint()
          ..color = const Color(0xFFDDD3BE)
          ..strokeWidth = s.width * .14
          ..style = PaintingStyle.stroke);
    c.drawArc(
        r,
        -pi / 2,
        2 * pi * pct,
        false,
        Paint()
          ..color = const Color(0xFFF6A92C)
          ..strokeWidth = s.width * .14
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke);
  }
}
