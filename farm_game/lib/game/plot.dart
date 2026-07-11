import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../economy.dart';
import '../state.dart';
import 'farm_game.dart';

class PlotComponent extends PositionComponent
    with TapCallbacks, HasGameReference<FarmGame> {
  final int index;
  late TextComponent _crop;
  late TextComponent _label;
  double _t = 0; // زمن محلي للتمايل

  PlotComponent({required this.index, required Vector2 position})
      : super(position: position);

  PlotData get data => GameState.I.plots[index];

  @override
  Future<void> onLoad() async {
    size = game.plotSize;
    _crop = TextComponent(
      text: '',
      anchor: Anchor.bottomCenter,
      position: Vector2(size.x / 2, size.y - 8),
      textRenderer: TextPaint(style: const TextStyle(fontSize: 30)),
    );
    _label = TextComponent(
      text: '',
      anchor: Anchor.center,
      position: size / 2,
      textRenderer: TextPaint(
          style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.bold)),
    );
    addAll([_crop, _label]);
  }

  @override
  void render(Canvas canvas) {
    final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(10));
    if (!data.unlocked) {
      canvas.drawRRect(rect, Paint()..color = Colors.black26);
      canvas.drawRRect(
          rect,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = Colors.white60);
      return;
    }
    // تربة بخطوط
    canvas.drawRRect(rect, Paint()..color = const Color(0xFF8A5A34));
    final line = Paint()..color = const Color(0xFF6E4526);
    for (double y = 6; y < size.y; y += 10) {
      canvas.drawRect(Rect.fromLTWH(4, y, size.x - 8, 3), line);
    }
    canvas.drawRRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFF5C3A1E));
    // شريط التقدم
    if (data.cropId != null && !data.ready) {
      final p = data.progress;
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(6, size.y - 7, size.x - 12, 4),
              const Radius.circular(2)),
          Paint()..color = Colors.black45);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(6, size.y - 7, (size.x - 12) * p, 4),
              const Radius.circular(2)),
          Paint()..color = const Color(0xFFFFD54F));
    }
  }

  @override
  void update(double dt) {
    _t += dt;
    if (!data.unlocked) {
      _crop.text = '';
      _label.text = '🔒 🪙${expandCost(GameState.I.expansions)}';
      return;
    }
    if (data.cropId == null) {
      _crop.text = '';
      _label.text = '＋';
      return;
    }
    _label.text = '';
    final spec = crops[data.cropId!]!;
    _crop.text = spec.emoji;
    if (data.ready) {
      // قفزة الجاهزية
      _crop.scale = Vector2.all(1.0 + 0.12 * sin(_t * 6).abs());
      _crop.angle = 0.06 * sin(_t * 6);
    } else {
      // نمو تدريجي + تمايل مع الريح
      final s = 0.4 + 0.6 * data.progress;
      _crop.scale = Vector2.all(s);
      _crop.angle = 0.07 * sin(_t * 2.4);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    final gs = GameState.I;
    if (!data.unlocked) {
      gs.unlockPlot(index);
      return;
    }
    if (data.cropId == null) {
      game.openSeedMenu(index);
    } else if (data.ready) {
      gs.harvest(index);
    } else {
      gs.speedUpPlot(index); // 💎 تسريع بلمسة أثناء النمو
    }
  }
}
