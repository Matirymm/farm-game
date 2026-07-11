import 'dart:async' as dart_async;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../state.dart';
import 'plot.dart';
import 'animal.dart';

class FarmGame extends FlameGame {
  int? pendingPlotIndex; // القطعة المنتظرة لاختيار البذور
  dart_async.Timer? _tick;

  @override
  Color backgroundColor() => const Color(0xFF6AB140);

  @override
  Future<void> onLoad() async {
    // السماء
    add(RectangleComponent(
      size: Vector2(size.x, size.y * 0.20),
      paint: Paint()..color = const Color(0xFF9EDCF2),
      priority: -10,
    ));
    // الشمس والمباني والأشجار (نصوص إيموجي — تُستبدل لاحقاً بـ Sprites)
    _emoji('☀️', Vector2(size.x * 0.12, size.y * 0.07), 34);
    _emoji('🏡', Vector2(size.x * 0.82, size.y * 0.14), 44);
    _emoji('🏚️', Vector2(size.x * 0.50, size.y * 0.14), 44);
    _emoji('🌳', Vector2(size.x * 0.22, size.y * 0.16), 36);
    _emoji('🌲', Vector2(size.x * 0.65, size.y * 0.17), 30);

    // القطع الزراعية (شبكة 3×3 في النصف السفلي)
    final gs = GameState.I;
    for (var i = 0; i < gs.plots.length; i++) {
      add(PlotComponent(index: i, position: plotPosition(i)));
    }
    // الحيوانات المحفوظة
    for (final a in gs.animalsOwned) {
      add(AnimalComponent(data: a));
    }

    // نبض كل ثانية لحالة الحيوانات
    _tick = dart_async.Timer.periodic(
        const Duration(seconds: 1), (_) => GameState.I.tick());

    // عند شراء حيوان جديد من HUD نضيفه للخريطة
    GameState.I.addListener(_syncAnimals);
  }

  void _syncAnimals() {
    final existing =
        children.whereType<AnimalComponent>().map((c) => c.data).toSet();
    for (final a in GameState.I.animalsOwned) {
      if (!existing.contains(a)) add(AnimalComponent(data: a));
    }
  }

  Vector2 plotPosition(int i) {
    final col = i % 3, row = i ~/ 3;
    final w = size.x * 0.26;
    final x0 = size.x * 0.08, y0 = size.y * 0.42;
    return Vector2(x0 + col * (w + size.x * 0.05),
        y0 + row * (size.y * 0.17));
  }

  Vector2 get plotSize => Vector2(size.x * 0.26, size.y * 0.12);

  void openSeedMenu(int plotIndex) {
    pendingPlotIndex = plotIndex;
    overlays.add('seeds');
  }

  void _emoji(String e, Vector2 pos, double fontSize) {
    add(TextComponent(
      text: e,
      position: pos,
      anchor: Anchor.center,
      textRenderer: TextPaint(style: TextStyle(fontSize: fontSize)),
    ));
  }

  @override
  void onRemove() {
    _tick?.cancel();
    GameState.I.removeListener(_syncAnimals);
    super.onRemove();
  }
}
