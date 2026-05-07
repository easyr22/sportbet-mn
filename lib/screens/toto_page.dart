import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class TotoPage extends StatefulWidget {
  const TotoPage({super.key});
  @override
  State<TotoPage> createState() => _TotoPageState();
}

class _TotoPageState extends State<TotoPage> {
  final Map<int, String> _picks = {}; // matchIdx -> "1"/"X"/"2"

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Hero
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFA000), Color(0xFFE65100)],
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
                      const Text('TOTO 13',
                          style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      const Text('13 тоглолт зөв таахад 50,000,000₮ хүртэл',
                          style: TextStyle(color: Colors.white, fontSize: 13)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Bоооцоо: 1,000₮',
                            style: TextStyle(color: Color(0xFFE65100), fontSize: 12, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.confirmation_number, size: 80, color: Colors.white.withOpacity(0.3)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Status row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat('${_picks.length}/13', 'Сонгосон', AppColors.accent),
                _Stat('5,232', 'Тоглогчид', AppColors.blueLight),
                _Stat('48,200,000₮', 'Pool', AppColors.orange),
                _Stat('15ц 32м', 'Үлдсэн', AppColors.liveRed),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text('Тоглолтуудыг таамаглах',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 8),
          ...List.generate(_matches.length, (i) {
            final m = _matches[i];
            return _MatchRow(
              idx: i+1, m: m,
              pick: _picks[i],
              onPick: (p) => setState(() {
                if (_picks[i] == p) {
                  _picks.remove(i);
                } else {
                  _picks[i] = p;
                }
              }),
            );
          }),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _picks.length == 13 ? () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                backgroundColor: AppColors.accent,
                content: Text('TOTO 13 — Тань татагдсан! Амжилт хүсье 🍀'),
                behavior: SnackBarBehavior.floating,
              ));
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              disabledBackgroundColor: AppColors.surfaceHov,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: Text(
              _picks.length == 13 ? 'TOTO ТАТАХ — 1,000₮' : '${13 - _picks.length} тоглолт сонго',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _M {
  final String home, away, league;
  final double o1, ox, o2;
  const _M(this.home, this.away, this.league, this.o1, this.ox, this.o2);
}

const _matches = [
  _M('Manchester City', 'Arsenal', 'Premier League', 1.85, 3.60, 4.20),
  _M('Real Madrid', 'Barcelona', 'La Liga', 2.20, 3.40, 3.10),
  _M('Bayern Munich', 'Dortmund', 'Bundesliga', 1.65, 4.20, 5.00),
  _M('PSG', 'Marseille', 'Ligue 1', 1.55, 4.40, 5.80),
  _M('Inter', 'Juventus', 'Serie A', 2.10, 3.20, 3.40),
  _M('Liverpool', 'Tottenham', 'Premier League', 1.75, 3.80, 4.60),
  _M('Atletico Madrid', 'Sevilla', 'La Liga', 1.95, 3.30, 4.00),
  _M('AC Milan', 'Napoli', 'Serie A', 2.30, 3.10, 3.20),
  _M('Ajax', 'PSV', 'Eredivisie', 2.50, 3.50, 2.70),
  _M('Benfica', 'Porto', 'Primeira Liga', 2.40, 3.20, 2.90),
  _M('Boca Juniors', 'River Plate', 'Argentina', 2.60, 3.30, 2.70),
  _M('Flamengo', 'Palmeiras', 'Brazil', 2.20, 3.40, 3.10),
  _M('Galatasaray', 'Fenerbahce', 'Türkiye', 2.10, 3.30, 3.40),
];

class _Stat extends StatelessWidget {
  final String value, label;
  final Color color;
  const _Stat(this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      ],
    );
  }
}

class _MatchRow extends StatelessWidget {
  final int idx;
  final _M m;
  final String? pick;
  final ValueChanged<String> onPick;
  const _MatchRow({required this.idx, required this.m, required this.pick, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: pick != null ? AppColors.accent : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: pick != null ? AppColors.accent : AppColors.bg,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: Text('$idx',
                style: TextStyle(color: pick != null ? Colors.white : AppColors.textSecondary,
                    fontSize: 11, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${m.home} - ${m.away}',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                Text(m.league,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
              ],
            ),
          ),
          _Pick('1', m.o1, pick == '1', () => onPick('1')),
          const SizedBox(width: 4),
          _Pick('X', m.ox, pick == 'X', () => onPick('X')),
          const SizedBox(width: 4),
          _Pick('2', m.o2, pick == '2', () => onPick('2')),
        ],
      ),
    );
  }
}

class _Pick extends StatelessWidget {
  final String label;
  final double odds;
  final bool selected;
  final VoidCallback onTap;
  const _Pick(this.label, this.odds, this.selected, this.onTap);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 50, padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.oddsBtn,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontSize: 10)),
            Text(odds.toStringAsFixed(2),
                style: TextStyle(color: selected ? Colors.white : Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
