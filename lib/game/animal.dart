import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../economy.dart';
import '../state.dart';
import 'farm_game.dart';

/// حيوان يتجول في منطقة الرعي (بين المباني والحقول)
class AnimalComponent extends PositionComponent
    with TapCallbacks, HasGameReference<FarmGame> {
  final AnimalData data;
  late TextComponent _body;
  late TextComponent _bubble;
  final _rng = Random();

  Vector2 _target = Vector2.zero();
  bool _walking = false;
  double _idleTimer = 1.0;
  double _t = 0;
  static const _speed = 28.0; // بكسل/ثانية

  AnimalComponent({required this.data});

  AnimalSpec get spec => animals[data.type]!;

  @override
  Future<void> onLoad() async {
    size = Vector2(48, 48);
    anchor = Anchor.center;
    position = _randomPenPoint();
    _target = position.clone();

    _body = TextComponent(
      text: spec.emoji,
      anchor: Anchor.center,
      position: size / 2,
      textRenderer: TextPaint(style: const TextStyle(fontSize: 32)),
    );
    _bubble = TextComponent(
      text: '',
      anchor: Anchor.bottomCenter,
      position: Vector2(size.x / 2, -2),
      textRenderer: TextPaint(style: const TextStyle(fontSize: 15)),
    );
    addAll([_body, _bubble]);
  }

  Vector2 _randomPenPoint() {
    final s = game.size;
    return Vector2(
      s.x * (0.10 + _rng.nextDouble() * 0.75),
      s.y * (0.26 + _rng.nextDouble() * 0.10),
    );
  }

  @override
  void update(double dt) {
    _t += dt;
    // حالة الإنتاج تنتهي؟ (state.tick يتكفل بالتحويل، هنا العرض فقط)
    _bubble.text = switch (data.state) {
      'hungry' => '🍽️',
      'producing' => '⏳',
      _ => '${products[spec.productId]!.emoji}❗',
    };

    // سلوك التجول (يتوقف عن التجول عندما يكون المنتج جاهزاً)
    if (_walking) {
      final dir = _target - position;
      final dist = dir.length;
      if (dist < 3) {
        _walking = false;
        _idleTimer = 1.5 + _rng.nextDouble() * 3.5;
      } else {
        position += dir.normalized() * _speed * dt;
        // حركة المشي المتمايلة
        _body.angle = 0.10 * sin(_t * 9);
        _body.position.y = size.y / 2 - 3 * sin(_t * 9).abs();
      }
    } else {
      _body.angle = 0;
      _body.position.y = size.y / 2;
      // تنفّس خفيف أثناء الوقوف
      _body.scale = Vector2(1, 1 - 0.04 * (0.5 + 0.5 * sin(_t * 2.6)));
      _idleTimer -= dt;
      if (_idleTimer <= 0 && data.state != 'ready') {
        _target = _randomPenPoint();
        // انقلاب الاتجاه حسب جهة المشي
        _body.scale = Vector2(_target.x < position.x ? -1 : 1, 1);
        _walking = true;
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    final gs = GameState.I;
    switch (data.state) {
      case 'hungry':
        gs.feedAnimal(data);
      case 'producing':
        if (gs.gems > 0) {
          gs.gems--;
          data.endMs = DateTime.now().millisecondsSinceEpoch;
          gs.tick();
        }
      case 'ready':
        gs.collectAnimal(data);
    }
  }
}
