import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// انفجار جسيمات صغير عند الحصاد/الجمع
class Burst extends PositionComponent {
  final Color color;
  final List<_P> _ps;
  Burst(Vector2 pos, this.color)
      : _ps = () {
          final r = Random();
          return List.generate(
              10,
              (_) => _P(
                  Vector2((r.nextDouble() - .5) * 190,
                      -70 - r.nextDouble() * 130),
                  .55 + r.nextDouble() * .35));
        }() {
    position = pos;
    priority = 50;
  }

  @override
  void update(double dt) {
    var alive = false;
    for (final p in _ps) {
      if (p.life <= 0) continue;
      p.vel.y += 460 * dt;
      p.pos += p.vel * dt;
      p.life -= dt;
      if (p.life > 0) alive = true;
    }
    if (!alive) removeFromParent();
  }

  @override
  void render(Canvas c) {
    for (final p in _ps) {
      if (p.life <= 0) continue;
      final a = (p.life / .9 * 255).clamp(0, 255).round();
      c.drawCircle(Offset(p.pos.x, p.pos.y), 3 + p.life * 3,
          Paint()..color = color.withAlpha(a));
    }
  }
}

class _P {
  Vector2 pos = Vector2.zero();
  final Vector2 vel;
  double life;
  _P(this.vel, this.life);
}

/// نص يطفو للأعلى ويختفي (+1، أرباح، تنبيهات قصيرة)
class RiseText extends PositionComponent {
  double _life = 1.15;
  RiseText(Vector2 pos, String text, {Color color = Colors.white}) {
    position = pos;
    priority = 60;
    anchor = Anchor.center;
    add(TextComponent(
      text: text,
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: color,
          shadows: const [Shadow(blurRadius: 4, color: Color(0xAA000000))],
        ),
      ),
    ));
  }

  @override
  void update(double dt) {
    position.y -= 46 * dt;
    _life -= dt;
    if (_life <= 0) removeFromParent();
  }
}
