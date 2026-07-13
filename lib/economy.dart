import 'dart:math';

/// =====================================================
/// الاقتصاد — نفس أرقام وثيقة التصميم
/// profit_per_min = 1.0 × 0.93^tier
/// XP للمستوى n = 50 × n^1.85
/// ملاحظة: الأوقات بالثواني الآن للاختبار السريع.
/// عند الإطلاق: اضرب الأوقات ×60 (ثوانٍ → دقائق).
/// =====================================================

class CropSpec {
  final String id, nameAr;
  final int unlockLevel, seedCost, growSeconds, sellPrice, xp;
  const CropSpec(this.id, this.nameAr, this.unlockLevel, this.seedCost,
      this.growSeconds, this.sellPrice, this.xp);
}

class AnimalSpec {
  final String id, nameAr, productId;
  final int unlockLevel, price, produceSeconds;
  final Map<String, int> feed; // cropId -> كمية
  const AnimalSpec(this.id, this.nameAr, this.unlockLevel, this.price,
      this.feed, this.produceSeconds, this.productId);
}

class ProductSpec {
  final String id, nameAr;
  final int sellPrice;
  const ProductSpec(this.id, this.nameAr, this.sellPrice);
}

const crops = <String, CropSpec>{
  'wheat': CropSpec('wheat', 'قمح', 1, 1, 10, 3, 1),
  'corn': CropSpec('corn', 'ذرة', 2, 2, 20, 6, 2),
  'carrot': CropSpec('carrot', 'جزر', 4, 4, 35, 11, 3),
  'tomato': CropSpec('tomato', 'طماطم', 6, 8, 60, 26, 6),
  'cane': CropSpec('cane', 'قصب سكر', 8, 15, 100, 75, 12),
};

const products = <String, ProductSpec>{
  'egg': ProductSpec('egg', 'بيض', 12),
  'milk': ProductSpec('milk', 'حليب', 30),
  'wool': ProductSpec('wool', 'صوف', 70),
};

const animals = <String, AnimalSpec>{
  'chicken': AnimalSpec('chicken', 'دجاجة', 3, 20, {'wheat': 2}, 15, 'egg'),
  'cow': AnimalSpec('cow', 'بقرة', 6, 150, {'corn': 2}, 30, 'milk'),
  'sheep': AnimalSpec('sheep', 'خروف', 9, 500, {'wheat': 4}, 50, 'wool'),
};

const unlockMessages = <int, String>{
  2: 'الذرة',
  3: 'الدجاجة',
  4: 'الجزر',
  5: 'توسعة الأرض',
  6: 'الطماطم والبقرة',
  8: 'قصب السكر',
  9: 'الخروف',
};

/// XP المطلوب لإنهاء المستوى n
int xpNeeded(int level) => (50 * pow(level, 1.85)).round();

/// تكلفة توسعة القطعة رقم n (تصاعدية ×1.6)
int expandCost(int expansions) => (100 * pow(1.6, expansions)).round();

/// تكلفة ترقية المستودع (تصاعدية ×1.5)
int storageUpgradeCost(int upgrades) => (200 * pow(1.5, upgrades)).round();

int sellPriceOf(String id) =>
    crops[id]?.sellPrice ?? products[id]?.sellPrice ?? 0;

String nameOf(String id) => crops[id]?.nameAr ?? products[id]?.nameAr ?? id;
