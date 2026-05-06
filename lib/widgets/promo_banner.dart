import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PromoBanner extends StatefulWidget {
  const PromoBanner({super.key});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  final PageController _ctrl = PageController();
  int _current = 0;

  final List<_BannerData> _banners = const [
    _BannerData(
      title: '100% Угтваарын бонус',
      subtitle: 'Эхний орц дагалдсан 10,000₮ хүртэл бонус авах!',
      tag: 'ШИНЭ ТОГЛОГЧ',
      gradient: [Color(0xFFFF6B00), Color(0xFFFF3B5C)],
      icon: '🎁',
    ),
    _BannerData(
      title: 'Экспресс Бетэд +10%',
      subtitle: '5+ тоглолттой экспресс бетэд нэмэлт 10% ялалт!',
      tag: 'ЭКСПРЕСС',
      gradient: [Color(0xFF1A237E), Color(0xFF3949AB)],
      icon: '⚡',
    ),
    _BannerData(
      title: 'Thai Premier League',
      subtitle: 'Тайландын лигийн бүх тоглолтод 50+ маркет!',
      tag: '🇹🇭 ТАЙЛАНД',
      gradient: [Color(0xFF1B5E20), Color(0xFF388E3C)],
      icon: '⚽',
    ),
    _BannerData(
      title: 'Live Бет Тавих',
      subtitle: 'Тоглолтын явцад бет тавиад илүү их ялаарай!',
      tag: 'LIVE',
      gradient: [Color(0xFF880E4F), Color(0xFFAD1457)],
      icon: '🔴',
    ),
  ];

  @override
  void initState() {
    super.initState();
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return false;
      final next = (_current + 1) % _banners.length;
      _ctrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      return true;
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _ctrl,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final b = _banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: b.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              b.tag,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            b.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            b.subtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Авах',
                              style: TextStyle(
                                color: AppColors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(b.icon, style: const TextStyle(fontSize: 56)),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _current == i ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _current == i ? AppColors.orange : AppColors.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BannerData {
  final String title;
  final String subtitle;
  final String tag;
  final List<Color> gradient;
  final String icon;

  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.gradient,
    required this.icon,
  });
}
