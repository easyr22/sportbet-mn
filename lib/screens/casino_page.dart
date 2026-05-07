import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/slot_machine.dart';
import '../widgets/roulette.dart';

class CasinoPage extends StatelessWidget {
  final bool isLive;
  const CasinoPage({super.key, this.isLive = false});

  @override
  Widget build(BuildContext context) {
    final games = isLive ? _liveCasinoGames : _slotGames;
    final w = MediaQuery.of(context).size.width;
    final cols = w < 600 ? 2 : w < 900 ? 3 : w < 1300 ? 4 : 5;

    return Container(
      color: AppColors.bg,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _Hero(isLive: isLive),
          const SizedBox(height: 16),
          _CategoryRow(isLive: isLive),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department, color: AppColors.orange, size: 20),
                const SizedBox(width: 6),
                Text(isLive ? 'LIVE ШИРЭЭНҮҮД' : 'ТОП ТОГЛООМ',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                const Spacer(),
                Text('${games.length} тоглоом',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.85,
            ),
            itemCount: games.length,
            itemBuilder: (_, i) => _GameTile(game: games[i], isLive: isLive),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final bool isLive;
  const _Hero({required this.isLive});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLive
              ? [const Color(0xFF7B1FA2), const Color(0xFF1E5A99)]
              : [const Color(0xFFE53935), const Color(0xFFFF6B00)],
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(isLive ? '🎰 LIVE CASINO' : '🎰 КАЗИНО',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 10),
                Text(
                  isLive ? 'БОДИТ DEALER-ТЭЙ ТОГЛО!' : '500+ ТОГЛООМ — БОНУСТАЙ!',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  isLive
                      ? 'Bлэкжэк, Рулет, Баккара — 24/7'
                      : 'Анхны хадгаламж дээрээ 100% бонус',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(isLive ? Icons.live_tv : Icons.casino, size: 64, color: Colors.white.withOpacity(0.3)),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final bool isLive;
  const _CategoryRow({required this.isLive});
  @override
  Widget build(BuildContext context) {
    final cats = isLive
        ? ['Бүгд', 'Blackjack', 'Roulette', 'Baccarat', 'Poker', 'Game Shows', 'Mongolian']
        : ['Бүгд', 'Slot', 'Roulette', 'Blackjack', 'Jackpot', 'Аркад', 'Шинэ', 'Megaways'];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: i == 0 ? AppColors.accent : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: i == 0 ? AppColors.accent : AppColors.border),
          ),
          child: Text(cats[i],
              style: TextStyle(
                  color: i == 0 ? Colors.white : AppColors.textSecondary,
                  fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _Game {
  final String name, provider, emoji;
  final List<Color> colors;
  final bool jackpot;
  const _Game(this.name, this.provider, this.emoji, this.colors, {this.jackpot = false});
}

const _slotGames = [
  _Game('Sweet Bonanza', 'Pragmatic', '🍭', [Color(0xFFEC407A), Color(0xFF7B1FA2)], jackpot: true),
  _Game('Gates of Olympus', 'Pragmatic', '⚡', [Color(0xFF1E88E5), Color(0xFF6A1B9A)]),
  _Game('Big Bass Bonanza', 'Pragmatic', '🎣', [Color(0xFF26A69A), Color(0xFF1565C0)]),
  _Game('Wolf Gold', 'Pragmatic', '🐺', [Color(0xFF6D4C41), Color(0xFFFF6F00)]),
  _Game('Book of Dead', 'Play\'n GO', '📜', [Color(0xFFFFC107), Color(0xFFE65100)]),
  _Game('Reactoonz', 'Play\'n GO', '👽', [Color(0xFF7B1FA2), Color(0xFF00BCD4)], jackpot: true),
  _Game('Starburst', 'NetEnt', '💎', [Color(0xFF00ACC1), Color(0xFFFF6F00)]),
  _Game('Gonzo\'s Quest', 'NetEnt', '⚱️', [Color(0xFF8BC34A), Color(0xFF6D4C41)]),
  _Game('Mega Moolah', 'Microgaming', '🦁', [Color(0xFFFFA000), Color(0xFFE65100)], jackpot: true),
  _Game('Immortal Romance', 'Microgaming', '🧛', [Color(0xFF424242), Color(0xFFB71C1C)]),
  _Game('Dead or Alive 2', 'NetEnt', '🤠', [Color(0xFF6D4C41), Color(0xFFE65100)]),
  _Game('Bonanza Megaways', 'BTG', '⛏️', [Color(0xFF558B2F), Color(0xFFE65100)]),
  _Game('Aviator', 'Spribe', '✈️', [Color(0xFFE53935), Color(0xFF1E1E1E)], jackpot: true),
  _Game('JetX', 'SmartSoft', '🚀', [Color(0xFFE53935), Color(0xFF6A1B9A)]),
  _Game('Mines', 'Spribe', '💣', [Color(0xFFFFA000), Color(0xFF424242)]),
  _Game('Plinko', 'Spribe', '🟡', [Color(0xFF1E88E5), Color(0xFF7B1FA2)]),
  _Game('Crazy Time', 'Evolution', '🎪', [Color(0xFFE91E63), Color(0xFF7B1FA2)], jackpot: true),
  _Game('Sugar Rush', 'Pragmatic', '🍬', [Color(0xFFEC407A), Color(0xFFFFA000)]),
  _Game('Fruit Party', 'Pragmatic', '🍓', [Color(0xFFEF5350), Color(0xFF66BB6A)]),
  _Game('The Dog House', 'Pragmatic', '🐕', [Color(0xFFFFA726), Color(0xFF42A5F5)]),
];

const _liveCasinoGames = [
  _Game('Lightning Roulette', 'Evolution', '🎯', [Color(0xFFE53935), Color(0xFFFFA000)]),
  _Game('Crazy Time', 'Evolution', '🎪', [Color(0xFFE91E63), Color(0xFF7B1FA2)], jackpot: true),
  _Game('Monopoly Live', 'Evolution', '🎲', [Color(0xFF42A5F5), Color(0xFFE53935)]),
  _Game('Dream Catcher', 'Evolution', '🎡', [Color(0xFF7B1FA2), Color(0xFFE91E63)]),
  _Game('Speed Baccarat', 'Evolution', '🃏', [Color(0xFF1565C0), Color(0xFF000000)]),
  _Game('Blackjack VIP', 'Evolution', '♠️', [Color(0xFF2E7D32), Color(0xFF000000)]),
  _Game('Auto Roulette', 'Pragmatic', '🎰', [Color(0xFFB71C1C), Color(0xFF424242)]),
  _Game('Mega Wheel', 'Pragmatic', '🎡', [Color(0xFFE65100), Color(0xFF7B1FA2)]),
  _Game('Sweet Bonanza CandyLand', 'Pragmatic', '🍭', [Color(0xFFEC407A), Color(0xFF42A5F5)], jackpot: true),
  _Game('Texas Hold\'em', 'Evolution', '🎴', [Color(0xFF388E3C), Color(0xFF000000)]),
  _Game('Sic Bo', 'Evolution', '🎲', [Color(0xFFE53935), Color(0xFFFFA000)]),
  _Game('Deal or No Deal', 'Evolution', '💼', [Color(0xFFE65100), Color(0xFF1565C0)]),
];

class _GameTile extends StatelessWidget {
  final _Game game;
  final bool isLive;
  const _GameTile({required this.game, required this.isLive});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showComing(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: game.colors,
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3)),
          ],
        ),
        child: Stack(
          children: [
            // Decorative background pattern
            Positioned(
              right: -10, bottom: -10,
              child: Text(game.emoji,
                  style: TextStyle(fontSize: 80, color: Colors.white.withOpacity(0.15))),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top badges
                  Row(
                    children: [
                      if (isLive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.liveRed,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text('LIVE',
                              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                        ),
                      if (game.jackpot)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text('JACKPOT',
                              style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w800)),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(game.emoji, style: const TextStyle(fontSize: 36)),
                  const SizedBox(height: 4),
                  Text(game.name,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                  Text(game.provider,
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 9)),
                  const SizedBox(height: 4),
                  Container(
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(isLive ? 'СУУЛТ ОЛОХ' : 'ТОГЛОХ',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComing(BuildContext context) {
    final lname = game.name.toLowerCase();
    if (lname.contains('roulette') || lname.contains('wheel')) {
      showDialog(context: context, builder: (_) => RouletteDialog(gameName: game.name));
    } else {
      showDialog(context: context, builder: (_) => SlotMachineDialog(
        gameName: game.name, emoji: game.emoji, colors: game.colors,
      ));
    }
  }
}
