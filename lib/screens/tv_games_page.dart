import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class TvGamesPage extends StatefulWidget {
  const TvGamesPage({super.key});
  @override
  State<TvGamesPage> createState() => _TvGamesPageState();
}

class _TvGamesPageState extends State<TvGamesPage> {
  Timer? _timer;
  int _seconds = 47;
  final _rng = Random();
  int _last1 = 7, _last2 = 23, _last3 = 41;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _seconds--;
        if (_seconds <= 0) {
          _seconds = 60;
          _last3 = _last2; _last2 = _last1; _last1 = _rng.nextInt(80) + 1;
        }
      });
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cols = w < 600 ? 2 : 3;

    return Container(
      color: AppColors.bg,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Big draw display
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF7B1FA2)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text('LUCKY 7', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Дараагийн сугалаа: $_seconds сек',
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Ball(_last1, big: true),
                    const SizedBox(width: 10),
                    _Ball(_last2, big: true),
                    const SizedBox(width: 10),
                    _Ball(_last3, big: true),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('БООЦОО ТАВИХ',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text('Бусад TV тоглоом',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 8, mainAxisSpacing: 8,
              childAspectRatio: 1.3,
            ),
            itemCount: _games.length,
            itemBuilder: (_, i) => _TvGameTile(g: _games[i]),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Ball extends StatelessWidget {
  final int n;
  final bool big;
  const _Ball(this.n, {this.big = false});
  @override
  Widget build(BuildContext context) {
    final size = big ? 64.0 : 36.0;
    Color col;
    if (n <= 20) col = const Color(0xFFE53935);
    else if (n <= 40) col = const Color(0xFF1E88E5);
    else if (n <= 60) col = const Color(0xFF22B14C);
    else col = const Color(0xFFFFA000);
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [col, col.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: col.withOpacity(0.5), blurRadius: 10, spreadRadius: 1)],
      ),
      alignment: Alignment.center,
      child: Text('$n', style: TextStyle(color: Colors.white, fontSize: big ? 24 : 14, fontWeight: FontWeight.w900)),
    );
  }
}

class _TvGame {
  final String name, emoji;
  final List<Color> colors;
  const _TvGame(this.name, this.emoji, this.colors);
}

const _games = [
  _TvGame('Keno', '🎱', [Color(0xFFE53935), Color(0xFF7B1FA2)]),
  _TvGame('Lucky Wheel', '🎡', [Color(0xFFFFA000), Color(0xFFE65100)]),
  _TvGame('21 Toss', '🎲', [Color(0xFF1E88E5), Color(0xFF00BCD4)]),
  _TvGame('Quick Lotto', '🎟️', [Color(0xFF22B14C), Color(0xFF558B2F)]),
  _TvGame('Bingo Express', '📋', [Color(0xFFEC407A), Color(0xFF7B1FA2)]),
  _TvGame('Magic Cards', '🎴', [Color(0xFF6A1B9A), Color(0xFF1E88E5)]),
  _TvGame('Race 7', '🐎', [Color(0xFF6D4C41), Color(0xFFFFA000)]),
  _TvGame('Football Sim', '⚽', [Color(0xFF22B14C), Color(0xFF1565C0)]),
  _TvGame('Speed Roulette', '🎯', [Color(0xFFE53935), Color(0xFF424242)]),
];

class _TvGameTile extends StatelessWidget {
  final _TvGame g;
  const _TvGameTile({required this.g});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: g.colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(color: AppColors.liveRed, borderRadius: BorderRadius.circular(2)),
            child: const Text('LIVE',
                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
          ),
          const Spacer(),
          Text(g.emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(height: 4),
          Text(g.name,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
          const Text('Үргэлжилж байна',
              style: TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}
