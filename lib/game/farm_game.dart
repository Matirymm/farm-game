import 'dart:async' as dart_async;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import '../state.dart';
import 'scenery.dart';
import 'plot.dart';
import 'animal.dart';

/// عالم أكبر من الشاشة + كاميرا تتحرك بسحب الإصبع (مثل Hay Day)
class FarmGame extends FlameGame with PanDetector {
  static const double worldW = 1600, worldH = 1000;

  int? pendingPlotIndex;
  dart_async.Timer? _tick;
  double clock = 0;
  bool _ready = false;

  /// دورة يوم/ليل مدتها 4 دقائق (0 = ظهر، 0.5 = منتصف الليل)
  double get dayPhase => (clock % 240) / 240;

  @override
  Color backgroundColor() => const Color(0xFF5FA63A);

  @override
  Future<void> onLoad() async {
    world.add(GroundLayer());
    world.add(SunComponent(position: Vector2(180, 110)));
    for (var i = 0; i < 4; i++) {
      world.add(CloudComponent(seed: i));
    }
    world.add(BarnComponent(position: Vector2(360, 250)));
    world.add(HouseComponent(position: Vector2(1300, 245)));
    world.add(TreeComponent(position: Vector2(120, 460), scale2: 1.0));
    world.add(TreeComponent(position: Vector2(1070, 470), scale2: .85));
    world.add(TreeComponent(position: Vector2(1510, 500), scale2: 1.1));
    world.add(TreeComponent(position: Vector2(760, 440), scale2: .7));

    final gs = GameState.I;
    for (var i = 0; i < gs.plots.length; i++) {
      world.add(PlotComponent(index: i, position: plotPosition(i)));
    }
    for (final a in gs.animalsOwned) {
      world.add(AnimalComponent(data: a));
    }

    camera.viewfinder.anchor = Anchor.center;
    _fitCamera();
    camera.viewfinder.position = Vector2(worldW * .58, worldH * .62);
    _clampCamera();
    camera.viewport.add(DayNightTint());

    _tick = dart_async.Timer.periodic(
        const Duration(seconds: 1), (_) => GameState.I.tick());
    GameState.I.addListener(_syncAnimals);
    _ready = true;
  }

  // ---------- الكاميرا: سحب + حدود ----------
  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (!_ready) return;
    camera.viewfinder.position -=
        info.delta.global / camera.viewfinder.zoom;
    _clampCamera();
  }

  void _fitCamera() {
    camera.viewfinder.zoom = max(size.y / worldH, size.x / worldW);
  }

  void _clampCamera() {
    final z = camera.viewfinder.zoom;
    final halfW = size.x / z / 2, halfH = size.y / z / 2;
    final p = camera.viewfinder.position;
    camera.viewfinder.position = Vector2(
      p.x.clamp(halfW, worldW - halfW).toDouble(),
      p.y.clamp(halfH, worldH - halfH).toDouble(),
    );
  }

  @override
  void onGameResize(Vector2 s) {
    super.onGameResize(s);
    if (_ready) {
      _fitCamera();
      _clampCamera();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    clock += dt;
  }

  // ---------- منطق اللعبة ----------
  void _syncAnimals() {
    final existing =
        world.children.whereType<AnimalComponent>().map((c) => c.data).toSet();
    for (final a in GameState.I.animalsOwned) {
      if (!existing.contains(a)) world.add(AnimalComponent(data: a));
    }
  }

  Vector2 plotPosition(int i) {
    final col = i % 3, row = i ~/ 3;
    return Vector2(830 + col * 205.0, 545 + row * 148.0);
  }

  Vector2 get plotSize => Vector2(170, 118);

  void openSeedMenu(int plotIndex) {
    pendingPlotIndex = plotIndex;
    overlays.add('seeds');
  }

  @override
  void onRemove() {
    _tick?.cancel();
    GameState.I.removeListener(_syncAnimals);
    super.onRemove();
  }
}
