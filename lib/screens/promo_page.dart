import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PromoPage extends StatelessWidget {
  const PromoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Featured promo
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF22B14C), Color(0xFF1E5A99)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text('🎁 ШИНЭ ХЭРЭГЛЭГЧДЭД',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(height: 12),
                      const Text('100% БОНУС',
                          style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, height: 1.0)),
                      const SizedBox(height: 6),
                      const Text('Эхний хадгаламж дээрээ 300,000₮ хүртэл',
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('БОНУС АВАХ',
                            style: TextStyle(color: AppColors.blueDark, fontSize: 12, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.card_giftcard, size: 96, color: Colors.white.withOpacity(0.3)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Бүх урамшуулал',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          ..._promos.map((p) => _PromoCard(p: p)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Promo {
  final String emoji, title, desc, badge;
  final List<Color> colors;
  const _Promo(this.emoji, this.title, this.desc, this.badge, this.colors);
}

const _promos = [
  _Promo('💰', 'Тогтмол хэрэглэгчийн бонус', 'Долоо хоног бүр 50% буцаан төлөлт хийгдэнэ', '50%',
      [Color(0xFFFFA000), Color(0xFFE65100)]),
  _Promo('⚡', 'Аккумулятор бонус', '5+ тоглолттой акк дээр 10% нэмэлт хожлого', '+10%',
      [Color(0xFF1E88E5), Color(0xFF6A1B9A)]),
  _Promo('🔥', 'Лайв бооцооны cashback', 'Лайв тоглолтын алдсан бооцоонд 20% буцаан төлөлт', '20%',
      [Color(0xFFE53935), Color(0xFFFF6B00)]),
  _Promo('🎰', 'Казино free spin', 'Эхний хадгаламж дээр 100 free spin', '100 FS',
      [Color(0xFFEC407A), Color(0xFF7B1FA2)]),
  _Promo('🏆', 'Champions League promo', 'CL тоглолтын акк дээр 25% бонус', '25%',
      [Color(0xFF1565C0), Color(0xFF26A69A)]),
  _Promo('👥', 'Найз урих', 'Найзаа татаж 30,000₮ авна', '30,000₮',
      [Color(0xFF22B14C), Color(0xFF00897B)]),
  _Promo('🎮', 'Эспорт promo', 'CS2/Dota2/LoL — 15% буцаан', '15%',
      [Color(0xFF7B1FA2), Color(0xFF3949AB)]),
  _Promo('📱', 'Мобайл бонус', 'Мобайлаар анхны бооцоонд 5,000₮', '5,000₮',
      [Color(0xFF424242), Color(0xFF1565C0)]),
  _Promo('🎂', 'Төрсөн өдрийн бэлэг', 'Төрсөн өдөр нь хэрэглэгчид free bet', 'Free Bet',
      [Color(0xFFEC407A), Color(0xFFFFA000)]),
  _Promo('🌟', 'VIP клуб', '5 түвшний VIP, эксклюзив урамшуулал', 'VIP',
      [Color(0xFFFFD700), Color(0xFF6D4C41)]),
];

class _PromoCard extends StatelessWidget {
  final _Promo p;
  const _PromoCard({required this.p});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppColors.accent,
          content: Text('${p.title} — Активлагдлаа! ${p.badge}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ));
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: p.colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8), bottomLeft: Radius.circular(8),
              ),
            ),
            alignment: Alignment.center,
            child: Text(p.emoji, style: const TextStyle(fontSize: 36)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(p.badge,
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(p.desc,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
