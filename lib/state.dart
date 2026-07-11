import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'economy.dart';

/// حالة قطعة أرض — المؤقتات epoch بالمللي ثانية،
/// لذلك النمو يستمر أثناء إغلاق اللعبة تلقائياً.
class PlotData {
  bool unlocked;
  String? cropId;
  int endMs = 0, totalMs = 0;
  PlotData({this.unlocked = false});

  bool get ready =>
      cropId != null && DateTime.now().millisecondsSinceEpoch >= endMs;
  double get progress {
    if (cropId == null || totalMs == 0) return 0;
    final left = endMs - DateTime.now().millisecondsSinceEpoch;
    return (1 - left / totalMs).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() =>
      {'u': unlocked, 'c': cropId, 'e': endMs, 't': totalMs};
  static PlotData fromJson(Map<String, dynamic> j) => PlotData()
    ..unlocked = j['u'] ?? false
    ..cropId = j['c']
    ..endMs = j['e'] ?? 0
    ..totalMs = j['t'] ?? 0;
}

class AnimalData {
  final String type;
  String state; // hungry | producing | ready
  int endMs = 0;
  AnimalData(this.type, {this.state = 'hungry'});

  Map<String, dynamic> toJson() => {'t': type, 's': state, 'e': endMs};
  static AnimalData fromJson(Map<String, dynamic> j) =>
      AnimalData(j['t'], state: j['s'] ?? 'hungry')..endMs = j['e'] ?? 0;
}

class GameState extends ChangeNotifier {
  GameState._();
  static final GameState I = GameState._();

  int coins = 50, gems = 10, xp = 0, level = 1;
  int storageCap = 50, storageUps = 0, expansions = 0;
  final Map<String, int> inv = {};
  final List<PlotData> plots =
      List.generate(9, (i) => PlotData(unlocked: i < 4));
  final List<AnimalData> animalsOwned = [];

  /// رسالة صعود المستوى الأخيرة (تعرضها HUD)
  String? levelUpMessage;

  int get invTotal => inv.values.fold(0, (a, b) => a + b);

  // ---------- الإجراءات ----------
  void addXp(int n) {
    xp += n;
    while (xp >= xpNeeded(level)) {
      xp -= xpNeeded(level);
      level++;
      final g = 1 + level ~/ 5;
      gems += g;
      final unlock = unlockMessages[level];
      levelUpMessage =
          'المستوى $level! +$g 💎${unlock != null ? ' — فتح: $unlock' : ''}';
    }
    _saveAndNotify();
  }

  bool addItem(String id, int n) {
    if (invTotal + n > storageCap) return false;
    inv[id] = (inv[id] ?? 0) + n;
    _saveAndNotify();
    return true;
  }

  bool plant(int plotIndex, String cropId) {
    final c = crops[cropId]!;
    if (coins < c.seedCost || level < c.unlockLevel) return false;
    coins -= c.seedCost;
    final p = plots[plotIndex];
    p.cropId = cropId;
    p.totalMs = c.growSeconds * 1000;
    p.endMs = DateTime.now().millisecondsSinceEpoch + p.totalMs;
    _saveAndNotify();
    return true;
  }

  bool harvest(int plotIndex) {
    final p = plots[plotIndex];
    if (!p.ready || p.cropId == null) return false;
    final c = crops[p.cropId!]!;
    if (!addItem(p.cropId!, 1)) return false;
    p.cropId = null;
    addXp(c.xp);
    return true;
  }

  bool unlockPlot(int plotIndex) {
    if (level < 5) return false;
    final cost = expandCost(expansions);
    if (coins < cost) return false;
    coins -= cost;
    expansions++;
    plots[plotIndex].unlocked = true;
    _saveAndNotify();
    return true;
  }

  bool buyAnimal(String type) {
    final a = animals[type]!;
    if (coins < a.price || level < a.unlockLevel) return false;
    coins -= a.price;
    animalsOwned.add(AnimalData(type));
    _saveAndNotify();
    return true;
  }

  bool feedAnimal(AnimalData a) {
    final spec = animals[a.type]!;
    final can = spec.feed.entries.every((e) => (inv[e.key] ?? 0) >= e.value);
    if (!can || a.state != 'hungry') return false;
    spec.feed.forEach((k, v) => inv[k] = inv[k]! - v);
    a.state = 'producing';
    a.endMs =
        DateTime.now().millisecondsSinceEpoch + spec.produceSeconds * 1000;
    _saveAndNotify();
    return true;
  }

  bool collectAnimal(AnimalData a) {
    if (a.state != 'ready') return false;
    final spec = animals[a.type]!;
    if (!addItem(spec.productId, 1)) return false;
    a.state = 'hungry';
    addXp(3);
    return true;
  }

  int sellAll(String id) {
    final q = inv[id] ?? 0;
    if (q == 0) return 0;
    final earned = sellPriceOf(id) * q;
    coins += earned;
    inv[id] = 0;
    _saveAndNotify();
    return earned;
  }

  bool upgradeStorage() {
    final cost = storageUpgradeCost(storageUps);
    if (coins < cost) return false;
    coins -= cost;
    storageUps++;
    storageCap += 25;
    _saveAndNotify();
    return true;
  }

  void speedUpPlot(int plotIndex) {
    if (gems < 1) return;
    gems--;
    plots[plotIndex].endMs = DateTime.now().millisecondsSinceEpoch;
    _saveAndNotify();
  }

  /// تُستدعى كل ثانية من حلقة اللعبة لتحويل producing → ready
  void tick() {
    var changed = false;
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final a in animalsOwned) {
      if (a.state == 'producing' && now >= a.endMs) {
        a.state = 'ready';
        changed = true;
      }
    }
    if (changed) _saveAndNotify();
  }

  // ---------- الحفظ / التحميل ----------
  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
        'save',
        jsonEncode({
          'coins': coins,
          'gems': gems,
          'xp': xp,
          'level': level,
          'cap': storageCap,
          'ups': storageUps,
          'exp': expansions,
          'inv': inv,
          'plots': plots.map((p) => p.toJson()).toList(),
          'animals': animalsOwned.map((a) => a.toJson()).toList(),
        }));
  }

  void _saveAndNotify() {
    notifyListeners();
    _save();
  }

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString('save');
    if (raw == null) return;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      coins = j['coins'] ?? 50;
      gems = j['gems'] ?? 10;
      xp = j['xp'] ?? 0;
      level = j['level'] ?? 1;
      storageCap = j['cap'] ?? 50;
      storageUps = j['ups'] ?? 0;
      expansions = j['exp'] ?? 0;
      inv
        ..clear()
        ..addAll(Map<String, int>.from(j['inv'] ?? {}));
      final pl = (j['plots'] as List?) ?? [];
      for (var i = 0; i < pl.length && i < plots.length; i++) {
        plots[i] = PlotData.fromJson(pl[i]);
      }
      animalsOwned
        ..clear()
        ..addAll(((j['animals'] as List?) ?? [])
            .map((a) => AnimalData.fromJson(a)));
    } catch (_) {
      // حفظ تالف؟ نبدأ من جديد بدل الانهيار
    }
  }
}
