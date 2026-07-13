import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'farm_game.dart';

/// الأرضية الكاملة: سماء متدرجة، تلال، عشب، ممر ترابي، سياج حظيرة الرعي.
class GroundLayer extends PositionComponent {
  GroundLayer() {
    priority = -20;
    size = Vector2(FarmGame.worldW, FarmGame.worldH);
  }

  final _speckles = () {
    final r = Random(7);
    return List.generate(
        140,
        (_) => Offset(r.nextDouble() * FarmGame.worldW,
            300 + r.nextDouble() * (FarmGame.worldH - 320)));
  }();

  @override
  void render(Canvas c) {
    // السماء
    c.drawRect(
        Rect.fromLTWH(0, 0, size.x, 300),
        Paint()
          ..shader = ui.Gradient.linear(const Offset(0, 0),
              const Offset(0, 300), const [
            Color(0xFF7EC8E8),
            Color(0xFFCDEBF7),
          ]));
    // تلال بعيدة
    final hill = Paint()..color = const Color(0xFF9AD46B);
    c.drawOval(Rect.fromCenter(center: Offset(size.x * .25, 300), width: 700, height: 190), hill);
    c.drawOval(Rect.fromCenter(center: Offset(size.x * .75, 305), width: 850, height: 160), hill);
    // العشب
    c.drawRect(
        Rect.fromLTWH(0, 255, size.x, size.y - 255),
        Paint()
          ..shader = ui.Gradient.linear(const Offset(0, 255),
              Offset(0, size.y), const [
            Color(0xFF86CC58),
            Color(0xFF5FA63A),
          ]));
    // تنقيط عشبي خفيف
    final sp = Paint()..color = const Color(0x145C3A1E);
    for (final o in _speckles) {
      c.drawOval(Rect.fromCenter(center: o, width: 14, height: 5), sp);
    }
    // ممر ترابي من الحظيرة إلى الحقول
    final path = Path()
      ..moveTo(420, 400)
      ..quadraticBezierTo(560, 560, 830, 610)
      ..quadraticBezierTo(1000, 640, 1150, 620);
    c.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFC9A46B)
          ..strokeWidth = 52
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke);
    c.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFB8905A)
          ..strokeWidth = 40
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke);
    // مرعى الحيوانات: أرضية أفتح + سياج خشبي
    final pen = RRect.fromRectAndRadius(
        const Rect.fromLTRB(160, 470, 700, 830), const Radius.circular(26));
    c.drawRRect(pen, Paint()..color = const Color(0x2295D46B));
    _fence(c, pen.outerRect);
  }

  void _fence(Canvas c, Rect r) {
    final post = Paint()..color = const Color(0xFF8A5A34);
    final rail = Paint()
      ..color = const Color(0xFFA5713F)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    void postAt(double x, double y) => c.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, y), width: 10, height: 30),
            const Radius.circular(3)),
        post);
    // أعمدة وعوارض على المحيط
    for (double x = r.left; x <= r.right; x += 68) {
      postAt(x, r.top);
      postAt(x, r.bottom);
    }
    for (double y = r.top; y <= r.bottom; y += 68) {
      postAt(r.left, y);
      postAt(r.right, y);
    }
    for (final dy in [-7.0, 5.0]) {
      c.drawLine(Offset(r.left, r.top + dy), Offset(r.right, r.top + dy), rail);
      c.drawLine(Offset(r.left, r.bottom + dy), Offset(r.right, r.bottom + dy), rail);
      c.drawLine(Offset(r.left + dy, r.top), Offset(r.left + dy, r.bottom), rail);
      c.drawLine(Offset(r.right + dy, r.top), Offset(r.right + dy, r.bottom), rail);
    }
  }
}

class SunComponent extends PositionComponent {
  SunComponent({required Vector2 position})
      : super(position: position, size: Vector2.all(120), anchor: Anchor.center);

  @override
  void render(Canvas c) {
    final center = Offset(size.x / 2, size.y / 2);
    c.drawCircle(
        center,
        58,
        Paint()
          ..shader = ui.Gradient.radial(center, 58, const [
            Color(0x66FFD93B),
            Color(0x00FFD93B),
          ]));
    c.drawCircle(
        center,
        27,
        Paint()
          ..shader = ui.Gradient.radial(
              center.translate(-6, -6), 30, const [
            Color(0xFFFFF3C2),
            Color(0xFFFFC63B),
          ]));
  }
}

class CloudComponent extends PositionComponent {
  final int seed;
  late double _speed;
  CloudComponent({required this.seed}) {
    final r = Random(seed * 31 + 5);
    position = Vector2(r.nextDouble() * FarmGame.worldW, 40 + r.nextDouble() * 140);
    _speed = 9 + r.nextDouble() * 10;
    scale = Vector2.all(0.7 + r.nextDouble() * 0.7);
    priority = -15;
    size = Vector2(110, 46);
  }

  @override
  void update(double dt) {
    position.x += _speed * dt;
    if (position.x > FarmGame.worldW + 140) position.x = -140;
  }

  @override
  void render(Canvas c) {
    final shadow = Paint()..color = const Color(0x22508AA8);
    final white = Paint()..color = const Color(0xF7FFFFFF);
    for (final p in [shadow, white]) {
      final dy = p == shadow ? 4.0 : 0.0;
      c.drawCircle(Offset(24, 26 + dy), 20, p);
      c.drawCircle(Offset(52, 16 + dy), 26, p);
      c.drawCircle(Offset(84, 26 + dy), 20, p);
      c.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(14, 20 + dy, 82, 22),
              const Radius.circular(12)),
          p);
    }
  }
}

class HouseComponent extends PositionComponent {
  HouseComponent({required Vector2 position})
      : super(position: position, size: Vector2(230, 190), anchor: Anchor.center);

  @override
  void render(Canvas c) {
    final w = size.x, h = size.y;
    // مدخنة
    c.drawRect(Rect.fromLTWH(w * .70, h * .06, w * .09, h * .22),
        Paint()..color = const Color(0xFF8A4A38));
    // جدار
    final wall = RRect.fromRectAndRadius(
        Rect.fromLTRB(w * .12, h * .38, w * .88, h * .96),
        const Radius.circular(8));
    c.drawRRect(wall, Paint()..color = const Color(0xFFF2E2C4));
    c.drawRRect(
        wall,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFF7A5C3A));
    // سقف
    final roof = Path()
      ..moveTo(0, h * .42)
      ..lineTo(w * .5, h * .02)
      ..lineTo(w, h * .42)
      ..close();
    c.drawPath(roof, Paint()..color = const Color(0xFFA64B33));
    c.drawRect(Rect.fromLTWH(0, h * .40, w, h * .045),
        Paint()..color = const Color(0xFF7E3626));
    // باب
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTRB(w * .43, h * .62, w * .57, h * .96),
            const Radius.circular(7)),
        Paint()..color = const Color(0xFF7A4A2B));
    c.drawCircle(Offset(w * .54, h * .80), 3, Paint()..color = const Color(0xFFE8C86B));
    // نافذتان
    for (final x in [w * .21, w * .67]) {
      final win = Rect.fromLTWH(x, h * .52, w * .13, w * .13);
      c.drawRect(win, Paint()..color = const Color(0xFFBEE3F0));
      c.drawRect(
          win,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = Colors.white);
      c.drawLine(win.centerLeft, win.centerRight, Paint()..color = Colors.white..strokeWidth = 2);
      c.drawLine(win.topCenter, win.bottomCenter, Paint()..color = Colors.white..strokeWidth = 2);
    }
  }
}

class BarnComponent extends PositionComponent {
  BarnComponent({required Vector2 position})
      : super(position: position, size: Vector2(250, 200), anchor: Anchor.center);

  @override
  void render(Canvas c) {
    final w = size.x, h = size.y;
    // جسم الحظيرة
    final body = RRect.fromRectAndRadius(
        Rect.fromLTRB(w * .06, h * .34, w * .94, h * .96),
        const Radius.circular(8));
    c.drawRRect(body, Paint()..color = const Color(0xFFB5402F));
    // سقف مزدوج الميل
    final roof = Path()
      ..moveTo(w * .01, h * .36)
      ..lineTo(w * .17, h * .10)
      ..lineTo(w * .50, h * .02)
      ..lineTo(w * .83, h * .10)
      ..lineTo(w * .99, h * .36)
      ..close();
    c.drawPath(roof, Paint()..color = const Color(0xFF7E2A1E));
    c.drawLine(Offset(w * .02, h * .36), Offset(w * .98, h * .36),
        Paint()..color = Colors.white..strokeWidth = 4);
    // نافذة علوية
    c.drawRect(Rect.fromCenter(center: Offset(w * .5, h * .22), width: w * .10, height: w * .10),
        Paint()..color = const Color(0xFFF7E9C8));
    // الباب الكبير مع تدعيمات X
    final door = RRect.fromRectAndRadius(
        Rect.fromLTRB(w * .34, h * .50, w * .66, h * .96),
        const Radius.circular(7));
    c.drawRRect(door, Paint()..color = const Color(0xFF8E3325));
    final trim = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    c.drawRRect(door, trim);
    c.drawLine(Offset(w * .34, h * .50), Offset(w * .66, h * .96), trim);
    c.drawLine(Offset(w * .66, h * .50), Offset(w * .34, h * .96), trim);
  }
}

class TreeComponent extends PositionComponent {
  final double scale2;
  double _t = 0;
  TreeComponent({required Vector2 position, this.scale2 = 1})
      : super(position: position, size: Vector2(120, 150), anchor: Anchor.bottomCenter) {
    scale = Vector2.all(scale2);
  }

  @override
  void update(double dt) => _t += dt;

  @override
  void render(Canvas c) {
    final w = size.x, h = size.y;
    // جذع
    final trunk = Path()
      ..moveTo(w * .44, h * .50)
      ..lineTo(w * .40, h)
      ..lineTo(w * .60, h)
      ..lineTo(w * .56, h * .50)
      ..close();
    c.drawPath(trunk, Paint()..color = const Color(0xFF7A5233));
    // أوراق متمايلة
    c.save();
    c.translate(w * .5, h * .55);
    c.rotate(sin(_t * 1.6) * 0.03);
    c.translate(-w * .5, -h * .55);
    final g1 = Paint()..color = const Color(0xFF4E8F35);
    final g2 = Paint()..color = const Color(0xFF6FB44A);
    c.drawCircle(Offset(w * .30, h * .40), w * .23, g1);
    c.drawCircle(Offset(w * .70, h * .40), w * .23, g1);
    c.drawCircle(Offset(w * .50, h * .26), w * .29, g1);
    c.drawCircle(Offset(w * .42, h * .26), w * .15, g2);
    c.restore();
  }
}

/// طبقة إضاءة اليوم/الليل — مثبتة على الشاشة (viewport)
class DayNightTint extends PositionComponent with HasGameReference<FarmGame> {
  DayNightTint() {
    priority = 100;
  }

  @override
  void update(double dt) {
    size = game.size;
  }

  @override
  void render(Canvas c) {
    final p = game.dayPhase; // 0 ظهر → 0.5 منتصف الليل → 1 ظهر
    final light = 0.5 + 0.5 * cos(2 * pi * p);
    final night = 1 - light;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    // غسق/فجر برتقالي عند الانتقال
    final duskA = (night * (1 - night) * 4 * 42).round().clamp(0, 42);
    if (duskA > 0) {
      c.drawRect(rect, Paint()..color = Color.fromARGB(duskA, 232, 120, 44));
    }
    // ليل أزرق
    final nightA = (pow(night, 1.5) * 115).round().clamp(0, 115);
    if (nightA > 0) {
      c.drawRect(rect, Paint()..color = Color.fromARGB(nightA, 11, 30, 60));
    }
  }
}
