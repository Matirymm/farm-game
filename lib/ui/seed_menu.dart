import 'package:flutter/material.dart';
import '../economy.dart';
import '../state.dart';
import '../game/farm_game.dart';
import 'icons.dart';

class SeedMenu extends StatelessWidget {
  final FarmGame game;
  const SeedMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final gs = GameState.I;
    return GestureDetector(
      onTap: () => game.overlays.remove('seeds'),
      child: Container(
        color: Colors.black54,
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
            decoration: const BoxDecoration(
              color: Color(0xFFFDF6E3),
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              border:
                  Border(top: BorderSide(color: Color(0xFFF6A92C), width: 4)),
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('اختر بذوراً',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...crops.values.map((c) {
                    final locked = gs.level < c.unlockLevel;
                    final poor = gs.coins < c.seedCost;
                    return ListTile(
                      dense: true,
                      leading: CropIcon(c.id),
                      title: Text(c.nameAr +
                          (locked ? '  (مستوى ${c.unlockLevel})' : '')),
                      subtitle: Text(
                          'النمو ${c.growSeconds} ث · البيع ${c.sellPrice} ذهب · ${c.xp} خبرة'),
                      trailing: FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF5FA63A)),
                        onPressed: locked || poor
                            ? null
                            : () {
                                gs.plant(game.pendingPlotIndex!, c.id);
                                game.overlays.remove('seeds');
                              },
                        child: Text('${c.seedCost} ذهب'),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
