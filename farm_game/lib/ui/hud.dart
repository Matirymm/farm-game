import 'package:flutter/material.dart';
import '../economy.dart';
import '../state.dart';
import '../game/farm_game.dart';

class Hud extends StatelessWidget {
  final FarmGame game;
  const Hud({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: GameState.I,
      builder: (context, _) {
        final gs = GameState.I;
        // رسالة صعود المستوى
        if (gs.levelUpMessage != null) {
          final msg = gs.levelUpMessage!;
          gs.levelUpMessage = null;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('🎉 $msg', textAlign: TextAlign.center),
                duration: const Duration(seconds: 3)));
          });
        }
        return SafeArea(
          child: Column(
            children: [
              // الشريط العلوي
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
                    _pill('🪙 ${gs.coins}'),
                    const SizedBox(width: 6),
                    _pill('💎 ${gs.gems}'),
                    const SizedBox(width: 6),
                    _pill('📦 ${gs.invTotal}/${gs.storageCap}'),
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
              // زر السوق
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFF6A92C)),
                  onPressed: () => _openMarket(context),
                  icon: const Text('🏪', style: TextStyle(fontSize: 20)),
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

  Widget _pill(String t) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
              color: const Color(0xFFFDF6E3),
              borderRadius: BorderRadius.circular(99)),
          child: Text(t,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13)),
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
          final items =
              gs.inv.entries.where((e) => e.value > 0).toList();
          return Directionality(
            textDirection: TextDirection.rtl,
            child: ListView(
              padding: const EdgeInsets.all(14),
              children: [
                const Text('📦 بيع المخزون',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('المخزون فارغ — احصد شيئاً 🌾'),
                  ),
                ...items.map((e) => ListTile(
                      leading: Text(emojiOf(e.key),
                          style: const TextStyle(fontSize: 26)),
                      title: Text('${nameOf(e.key)} ×${e.value}'),
                      trailing: FilledButton(
                        onPressed: () => gs.sellAll(e.key),
                        child:
                            Text('بيع 🪙${sellPriceOf(e.key) * e.value}'),
                      ),
                    )),
                const Divider(),
                const Text('🐄 شراء حيوانات',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ...animals.values.map((a) {
                  final locked = gs.level < a.unlockLevel;
                  return ListTile(
                    leading:
                        Text(a.emoji, style: const TextStyle(fontSize: 26)),
                    title: Text(a.nameAr +
                        (locked ? ' (مستوى ${a.unlockLevel})' : '')),
                    subtitle: Text(
                        'علف: ${a.feed.entries.map((e) => '${crops[e.key]!.emoji}×${e.value}').join(' ')} → ${products[a.productId]!.emoji}'),
                    trailing: FilledButton(
                      onPressed: locked || gs.coins < a.price
                          ? null
                          : () => gs.buyAnimal(a.id),
                      child: Text('🪙${a.price}'),
                    ),
                  );
                }),
                const Divider(),
                ListTile(
                  leading: const Text('🏗️', style: TextStyle(fontSize: 26)),
                  title: const Text('ترقية المستودع (+25)'),
                  trailing: FilledButton(
                    onPressed: gs.coins < storageUpgradeCost(gs.storageUps)
                        ? null
                        : () => gs.upgradeStorage(),
                    child: Text('🪙${storageUpgradeCost(gs.storageUps)}'),
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
