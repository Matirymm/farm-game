import 'package:flutter/material.dart';
import '../art/animal_art.dart';
import '../art/crop_art.dart';
import '../economy.dart';

/// أيقونات القوائم — نفس فن اللعبة المرسوم، بدون أي إيموجي
class CropIcon extends StatelessWidget {
  final String id;
  final double size;
  const CropIcon(this.id, {super.key, this.size = 36});

  @override
  Widget build(BuildContext context) => CustomPaint(
      size: Size(size, size), painter: _CropPainter(id));
}

class _CropPainter extends CustomPainter {
  final String id;
  _CropPainter(this.id);
  @override
  void paint(Canvas canvas, Size size) =>
      CropArt.paint(canvas, id, size, 1, true, 0.8);
  @override
  bool shouldRepaint(covariant _CropPainter old) => old.id != id;
}

class AnimalIcon extends StatelessWidget {
  final String type;
  final double size;
  const AnimalIcon(this.type, {super.key, this.size = 40});

  @override
  Widget build(BuildContext context) => CustomPaint(
      size: Size(size, size * .85), painter: _AnimalPainter(type));
}

class _AnimalPainter extends CustomPainter {
  final String type;
  _AnimalPainter(this.type);
  @override
  void paint(Canvas canvas, Size size) =>
      AnimalArt.paint(canvas, type, size, 0, false);
  @override
  bool shouldRepaint(covariant _AnimalPainter old) => old.type != type;
}

class ProductIcon extends StatelessWidget {
  final String id;
  final double size;
  const ProductIcon(this.id, {super.key, this.size = 34});

  @override
  Widget build(BuildContext context) => CustomPaint(
      size: Size(size, size), painter: _ProductPainter(id));
}

class _ProductPainter extends CustomPainter {
  final String id;
  _ProductPainter(this.id);
  @override
  void paint(Canvas canvas, Size size) =>
      AnimalArt.paintProduct(canvas, id, size);
  @override
  bool shouldRepaint(covariant _ProductPainter old) => old.id != id;
}

/// أيقونة موحدة لأي عنصر مخزون (محصول أو منتج حيواني)
class ItemIcon extends StatelessWidget {
  final String id;
  final double size;
  const ItemIcon(this.id, {super.key, this.size = 34});

  @override
  Widget build(BuildContext context) => crops.containsKey(id)
      ? CropIcon(id, size: size)
      : ProductIcon(id, size: size);
}
