import 'package:flutter/material.dart';
import '../economy.dart';
import '../state.dart';
import '../game/farm_game.dart';
import 'icons.dart';

class Hud extends StatelessWidget {
  final FarmGame game;
  const Hud({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: GameState.I,
      builder: (context, _) {
        final gs = GameState.I;
        if (gs.levelUpMessage != null) {
          final msg = gs.levelUpMessage!;
          gs.levelUpMessage = null;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(msg, textAlign: TextAlign.center),
                backgroundColor: const Color(0xFF3C2812),
                duration: const Duration(seconds: 3)));
          });
        }
        return SafeArea(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xEE3C2812),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(children: [
                  Row(children: [
                    _pill(Icons.monetization_on, const Color(0xFFF6A92C),
                        '${gs.coins}'),
                    const SizedBox(width: 6),
                    _pill(Icons.diamond, const Color(0xFF8E4CE0),
                        '${gs.gems}'),
                    const SizedBox(width: 6),
                    _pill(Icons.inventory_2, const Color(0xFF7A5C3A),
                        '${gs.invTotal}/${gs.storageCap}'),
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFF6A92C),
                      child: Text('${gs.level}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: gs.xp / xpNeeded(gs.level),
                          minHeight: 12,
                          backgroundColor: Colors.black38,
                          color: const Color(0xFF8FD45E),
                        ),
                      ),
                    ),
                  ]),
                ]),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFF6A92C),
                      foregroundColor: Colors.white),
                  onPressed: () => _openMarket(context),
                  icon: const Icon(Icons.storefront),
                  label: const Text('السوق والحظيرة',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _pill(IconData ic, Color color, String t) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
          decoration: BoxDecoration(
              color: const Color(0xFFFDF6E3),
              borderRadius: BorderRadius.circular(99)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(ic, size: 16, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(t,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ),
      );

  void _openMarket(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFDF6E3),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => AnimatedBuilder(
        animation: GameState.I,
        builder: (context, _) {
          final gs = GameState.I;
          final items = gs.inv.entries.where((e) => e.value > 0).toList();
          return Directionality(
            textDirection: TextDirection.rtl,
            child: ListView(
              padding: const EdgeInsets.all(14),
              children: [
                const Text('بيع المخزون',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('المخزون فارغ — احصد شيئاً أولاً'),
                  ),
                ...items.map((e) => ListTile(
                      leading: ItemIcon(e.key),
                      title: Text('${nameOf(e.key)} ×${e.value}'),
                      trailing: FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFF6A92C)),
                        onPressed: () => gs.sellAll(e.key),
                        child: Text('بيع ${sellPriceOf(e.key) * e.value}'),
                      ),
                    )),
                const Divider(),
                const Text('شراء حيوانات',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ...animals.values.map((a) {
                  final locked = gs.level < a.unlockLevel;
                  return ListTile(
                    leading: AnimalIcon(a.id),
                    title: Text(a.nameAr +
                        (locked ? ' (مستوى ${a.unlockLevel})' : '')),
                    subtitle: Text(
                        'علف: ${a.feed.entries.map((e) => '${e.value} ${crops[e.key]!.nameAr}').join(' + ')} → ${products[a.productId]!.nameAr}'),
                    trailing: FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF5FA63A)),
                      onPressed: locked || gs.coins < a.price
                          ? null
                          : () => gs.buyAnimal(a.id),
                      child: Text('${a.price} ذهب'),
                    ),
                  );
                }),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.warehouse,
                      size: 30, color: Color(0xFF7A5C3A)),
                  title: const Text('ترقية المستودع (+25 سعة)'),
                  trailing: FilledButton(
                    onPressed: gs.coins < storageUpgradeCost(gs.storageUps)
                        ? null
                        : () => gs.upgradeStorage(),
                    child:
                        Text('${storageUpgradeCost(gs.storageUps)} ذهب'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
