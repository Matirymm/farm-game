import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../art/crop_art.dart';
import '../economy.dart';
import '../state.dart';
import 'effects.dart';
import 'farm_game.dart';

class PlotComponent extends PositionComponent
    with TapCallbacks, HasGameReference<FarmGame> {
  final int index;
  double _t = 0;
  late TextComponent _priceLabel;

  PlotComponent({required this.index, required Vector2 position})
      : super(position: position);

  PlotData get data => GameState.I.plots[index];
  Vector2 get _center => position + size / 2;

  @override
  Future<void> onLoad() async {
    size = game.plotSize;
    _priceLabel = TextComponent(
      text: '',
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y * .68),
      textRenderer: TextPaint(
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
      ),
    );
    add(_priceLabel);
  }

  @override
  void update(double dt) {
    _t += dt;
    _priceLabel.text =
        data.unlocked ? '' : '${expandCost(GameState.I.expansions)} ذهب';
  }

  @override
  void render(Canvas c) {
    final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(12));

    if (!data.unlocked) {
      // قطعة مقفلة: عشب باهت + إطار متقطع + قفل مرسوم
      c.drawRRect(rect, Paint()..color = const Color(0x33203010));
      _dashedBorder(c, rect.outerRect);
      _padlock(c, Offset(size.x / 2, size.y * .36), size.x * .13);
      return;
    }

    // تربة محروثة
    c.drawRRect(rect, Paint()..color = const Color(0xFF8A5A34));
    final furrow = Paint()..color = const Color(0xFF6E4526);
    for (double y = 10; y < size.y - 8; y += 13) {
      c.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(7, y, size.x - 14, 4),
              const Radius.circular(2)),
          furrow);
    }
    // تربة رطبة أثناء النمو
    if (data.cropId != null && !data.ready) {
      c.drawRRect(rect, Paint()..color = const Color(0x1E2A1607));
    }
    c.drawRRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..color = const Color(0xFF5C3A1E));

    if (data.cropId == null) return;

    // النبتة
    c.save();
    c.translate(size.x * .13, size.y * .02);
    CropArt.paint(c, data.cropId!, Size(size.x * .74, size.y * .86),
        data.progress, data.ready, _t);
    c.restore();

    if (data.ready) {
      // توهج ذهبي نابض حول القطعة الجاهزة
      final a = (110 + 70 * sin(_t * 5)).round();
      c.drawRRect(
          rect.inflate(3),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..color = Color.fromARGB(a, 255, 200, 60));
    } else {
      // شريط تقدم
      final p = data.progress;
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(8, size.y - 9, size.x - 16, 5),
              const Radius.circular(3)),
          Paint()..color = const Color(0x66000000));
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(8, size.y - 9, (size.x - 16) * p, 5),
              const Radius.circular(3)),
          Paint()..color = const Color(0xFFFFD54F));
    }
  }

  void _dashedBorder(Canvas c, Rect r) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xAAFFFFFF);
    const dash = 12.0, gap = 8.0;
    for (double x = r.left; x < r.right; x += dash + gap) {
      c.drawLine(Offset(x, r.top), Offset(min(x + dash, r.right), r.top), p);
      c.drawLine(
          Offset(x, r.bottom), Offset(min(x + dash, r.right), r.bottom), p);
    }
    for (double y = r.top; y < r.bottom; y += dash + gap) {
      c.drawLine(Offset(r.left, y), Offset(r.left, min(y + dash, r.bottom)), p);
      c.drawLine(
          Offset(r.right, y), Offset(r.right, min(y + dash, r.bottom)), p);
    }
  }

  void _padlock(Canvas c, Offset at, double r) {
    final gold = Paint()..color = const Color(0xFFE8C86B);
    c.drawArc(
        Rect.fromCenter(center: at.translate(0, -r * .4), width: r * 1.2, height: r * 1.2),
        pi,
        pi,
        false,
        Paint()
          ..color = const Color(0xFFB8985A)
          ..strokeWidth = r * .32
          ..style = PaintingStyle.stroke);
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: at.translate(0, r * .35), width: r * 1.7, height: r * 1.4),
            Radius.circular(r * .3)),
        gold);
  }

  // ---------- اللمس ----------
  @override
  void onTapUp(TapUpEvent event) {
    final gs = GameState.I;
    if (!data.unlocked) {
      if (gs.level < 5) {
        game.world.add(RiseText(_center, 'يُفتح عند المستوى 5'));
      } else if (!gs.unlockPlot(index)) {
        game.world.add(RiseText(_center, 'الذهب لا يكفي',
            color: const Color(0xFFFFB4A8)));
      } else {
        game.world.add(Burst(_center, const Color(0xFF8FD45E)));
      }
      return;
    }
    if (data.cropId == null) {
      game.openSeedMenu(index);
    } else if (data.ready) {
      final id = data.cropId!;
      if (GameState.I.harvest(index)) {
        game.world.add(Burst(_center, const Color(0xFFFFC63B)));
        game.world.add(RiseText(_center, '+1 ${nameOf(id)}',
            color: const Color(0xFFFFE9A8)));
      } else {
        game.world.add(RiseText(_center, 'المستودع ممتلئ',
            color: const Color(0xFFFFB4A8)));
      }
    } else {
      final leftS =
          ((data.endMs - DateTime.now().millisecondsSinceEpoch) / 1000).ceil();
      game.world.add(
          RiseText(_center, 'باقٍ $leftS ث — اضغط مطولاً للتسريع'));
    }
  }

  @override
  void onLongTapDown(TapDownEvent event) {
    if (!data.unlocked || data.cropId == null || data.ready) return;
    final gs = GameState.I;
    if (gs.gems < 1) {
      game.world
          .add(RiseText(_center, 'لا يوجد ماس', color: const Color(0xFFFFB4A8)));
      return;
    }
    gs.speedUpPlot(index);
    game.world.add(Burst(_center, const Color(0xFFB07DF0)));
  }
}
