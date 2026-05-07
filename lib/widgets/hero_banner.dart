import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 700;
    if (isMobile) return _buildMobile(context);
    return Container(
      height: 180,
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 6),
      child: Row(
        children: [
          // Left: Welcome bonus
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E5A99), Color(0xFF22B14C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(20),
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
                    child: const Text('ШИНЭ ХЭРЭГЛЭГЧИЙН БОНУС',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 12),
                  const Text('100% БОНУС',
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1.0)),
                  const SizedBox(height: 4),
                  const Text('Эхний хадгаламж дээрээ 300,000₮ хүртэл',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
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
          ),
          const SizedBox(width: 8),
          // Middle: Live highlight
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.liveRed,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Text('LIVE',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 6),
                      const Text('Champions League',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Team('Barcelona', '⚽', Color(0xFF004D98)),
                      Column(
                        children: [
                          const Text('VS', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.bg,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text('1 - 0',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                          ),
                          const SizedBox(height: 4),
                          const Text("67'", style: TextStyle(color: AppColors.liveRed, fontSize: 11, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      _Team('Shakhtar', '⚽', Color(0xFFFF6600)),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _MiniOdds('1', '1.85'),
                      _MiniOdds('X', '3.20'),
                      _MiniOdds('2', '4.50'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Right: Mobile app promo
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF15497F), Color(0xFF0E1B2C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('МОБИЛ АПП',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                        SizedBox(height: 6),
                        Text('Татаад хэзээ ч, хаанаас ч бооцоо тавь',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.phone_iphone, color: Colors.white, size: 22),
                            SizedBox(width: 8),
                            Icon(Icons.android, color: Color(0xFFA4C639), size: 22),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.qr_code_2, size: 56, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Container(
      height: 110,
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E5A99), Color(0xFF22B14C)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text('БОНУС',
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 8),
                const Text('100% БОНУС',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, height: 1)),
                const SizedBox(height: 2),
                const Text('Эхний хадгаламж 300,000₮ хүртэл',
                    style: TextStyle(color: Colors.white, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('АВАХ',
                style: TextStyle(color: AppColors.blueDark, fontSize: 12, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _Team extends StatelessWidget {
  final String name;
  final String emoji;
  final Color color;
  const _Team(this.name, this.emoji, this.color);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _MiniOdds extends StatelessWidget {
  final String label, odds;
  const _MiniOdds(this.label, this.odds);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.oddsBtn,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
            const SizedBox(height: 2),
            Text(odds, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
