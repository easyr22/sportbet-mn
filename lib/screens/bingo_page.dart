import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class BingoPage extends StatefulWidget {
  const BingoPage({super.key});
  @override
  State<BingoPage> createState() => _BingoPageState();
}

class _BingoPageState extends State<BingoPage> {
  final _rng = Random();
  final List<int> _drawn = [];
  Timer? _timer;
  int _last = 0;

  @override
  void initState() {
    super.initState();
    // Pre-fill some numbers as if game already started
    final pool = List.generate(75, (i) => i + 1)..shuffle();
    _drawn.addAll(pool.take(15));
    _last = _drawn.last;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _drawNext());
  }

  void _drawNext() {
    if (_drawn.length >= 75) {
      _drawn.clear();
    }
    final pool = List.generate(75, (i) => i + 1)..removeWhere(_drawn.contains);
    if (pool.isEmpty) return;
    pool.shuffle(_rng);
    setState(() {
      _last = pool.first;
      _drawn.add(_last);
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  String _letter(int n) {
    if (n <= 15) return 'B';
    if (n <= 30) return 'I';
    if (n <= 45) return 'N';
    if (n <= 60) return 'G';
    return 'O';
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 700;

    return Container(
      color: AppColors.bg,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Hero
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE91E63), Color(0xFF7B1FA2)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('БИНГО',
                          style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      const Text('Шууд тоглож байна — 4 секунд тутамд шинэ дугаар',
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _InfoPill('Jackpot', '5,000,000₮', Colors.white, AppColors.blueDark),
                          const SizedBox(width: 8),
                          _InfoPill('Тоглогчид', '${248 + _drawn.length * 3}', AppColors.accent, Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isMobile) Icon(Icons.grid_4x4, size: 80, color: Colors.white.withOpacity(0.3)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Last drawn
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: Column(
              children: [
                const Text('СҮҮЛИЙН ДУГААР',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.elasticOut,
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.blue],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.accent.withOpacity(0.4), blurRadius: 20, spreadRadius: 4),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_letter(_last),
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                      Text('$_last',
                          style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, height: 1)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text('${_drawn.length}/75 дугаар татагдсан',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Drawn numbers grid
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Татагдсан дугаарууд',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: List.generate(75, (i) {
                    final n = i + 1;
                    final hit = _drawn.contains(n);
                    return Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: hit ? AppColors.accent : AppColors.bg,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: hit ? AppColors.accent : AppColors.border),
                      ),
                      alignment: Alignment.center,
                      child: Text('$n',
                          style: TextStyle(
                              color: hit ? Colors.white : AppColors.textMuted,
                              fontSize: 12, fontWeight: FontWeight.w700)),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label, value;
  final Color bg, fg;
  const _InfoPill(this.label, this.value, this.bg, this.fg);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: TextStyle(color: fg.withOpacity(0.8), fontSize: 11)),
          Text(value, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
