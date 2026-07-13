import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../art/animal_art.dart';
import '../economy.dart';
import '../state.dart';
import 'effects.dart';
import 'farm_game.dart';

/// حدود مرعى الحيوانات داخل السياج
const _penX1 = 210.0, _penX2 = 640.0, _penY1 = 520.0, _penY2 = 780.0;

class AnimalComponent extends PositionComponent
    with TapCallbacks, HasGameReference<FarmGame> {
  final AnimalData data;
  final _rng = Random();

  Vector2 _target = Vector2.zero();
  bool _walking = false, _faceLeft = false;
  double _idle = 1.0, _phase = 0, _t = 0;
  static const _speed = 34.0;

  AnimalComponent({required this.data});

  AnimalSpec get spec => animals[data.type]!;
  Vector2 get _head => position + Vector2(size.x / 2, 0);

  @override
  Future<void> onLoad() async {
    size = data.type == 'cow' ? Vector2(78, 62) : Vector2(58, 50);
    anchor = Anchor.center;
    position = Vector2(_penX1 + _rng.nextDouble() * (_penX2 - _penX1),
        _penY1 + _rng.nextDouble() * (_penY2 - _penY1));
    _target = position.clone();
    priority = 10;
  }

  @override
  void update(double dt) {
    _t += dt;
    if (_walking) {
      _phase += dt * 10;
      final dir = _target - position;
      if (dir.length < 3) {
        _walking = false;
        _idle = 1.5 + _rng.nextDouble() * 3.5;
      } else {
        position += dir.normalized() * _speed * dt;
      }
    } else {
      _idle -= dt;
      if (_idle <= 0 && data.state != 'ready') {
        _target = Vector2(_penX1 + _rng.nextDouble() * (_penX2 - _penX1),
            _penY1 + _rng.nextDouble() * (_penY2 - _penY1));
        _faceLeft = _target.x < position.x;
        _walking = true;
      }
    }
  }

  @override
  void render(Canvas c) {
    // ظل أرضي
    c.drawOval(
        Rect.fromCenter(
            center: Offset(size.x / 2, size.y - 2),
            width: size.x * .68,
            height: 9),
        Paint()..color = const Color(0x33203010));
    // الجسم (انعكاس حسب الاتجاه + وثب المشي/تنفس الوقوف)
    c.save();
    final bob = _walking ? sin(_phase) * 1.8 : sin(_t * 2.6) * 0.8;
    c.translate(0, bob);
    if (_faceLeft) {
      c.translate(size.x, 0);
      c.scale(-1, 1);
    }
    AnimalArt.paint(
        c, data.type, Size(size.x, size.y - 4), _phase, _walking);
    c.restore();
    // فقاعة الحالة
    _bubble(c);
  }

  void _bubble(Canvas c) {
    final bw = 30.0, bh = 26.0;
    final bx = size.x / 2 - bw / 2, by = -bh - 8.0;
    final float = sin(_t * 3) * 2;
    c.save();
    c.translate(0, float);
    final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(bx, by, bw, bh), const Radius.circular(8));
    c.drawRRect(r, Paint()..color = Colors.white);
    c.drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = const Color(0xFFB8AD98));
    final tip = Path()
      ..moveTo(size.x / 2 - 5, by + bh)
      ..lineTo(size.x / 2, by + bh + 6)
      ..lineTo(size.x / 2 + 5, by + bh)
      ..close();
    c.drawPath(tip, Paint()..color = Colors.white);

    c.translate(bx + 4, by + 4);
    final inner = Size(bw - 8, bh - 8);
    switch (data.state) {
      case 'hungry':
        AnimalArt.paintFeedIcon(c, inner);
      case 'producing':
        final total = spec.produceSeconds * 1000;
        final left = data.endMs - DateTime.now().millisecondsSinceEpoch;
        AnimalArt.paintProgress(
            c, inner, (1 - left / total).clamp(0.0, 1.0));
      default:
        AnimalArt.paintProduct(c, spec.productId, inner);
    }
    c.restore();
  }

  // ---------- اللمس ----------
  @override
  void onTapUp(TapUpEvent event) {
    final gs = GameState.I;
    switch (data.state) {
      case 'hungry':
        if (gs.feedAnimal(data)) {
          game.world.add(Burst(_head, const Color(0xFF8FD45E)));
        } else {
          final need = spec.feed.entries
              .map((e) => '${e.value} ${crops[e.key]!.nameAr}')
              .join(' + ');
          game.world.add(RiseText(_head, 'يلزم علف: $need',
              color: const Color(0xFFFFB4A8)));
        }
      case 'producing':
        final leftS =
            ((data.endMs - DateTime.now().millisecondsSinceEpoch) / 1000)
                .ceil();
        game.world
            .add(RiseText(_head, 'باقٍ $leftS ث — مطولاً للتسريع'));
      case 'ready':
        if (gs.collectAnimal(data)) {
          game.world.add(Burst(_head, Colors.white));
          game.world.add(RiseText(
              _head, '+1 ${products[spec.productId]!.nameAr}',
              color: const Color(0xFFFFE9A8)));
        } else {
          game.world.add(RiseText(_head, 'المستودع ممتلئ',
              color: const Color(0xFFFFB4A8)));
        }
    }
  }

  @override
  void onLongTapDown(TapDownEvent event) {
    if (data.state != 'producing') return;
    final gs = GameState.I;
    if (gs.gems < 1) {
      game.world
          .add(RiseText(_head, 'لا يوجد ماس', color: const Color(0xFFFFB4A8)));
      return;
    }
    gs.gems--;
    data.endMs = DateTime.now().millisecondsSinceEpoch;
    gs.tick();
    game.world.add(Burst(_head, const Color(0xFFB07DF0)));
  }
}
