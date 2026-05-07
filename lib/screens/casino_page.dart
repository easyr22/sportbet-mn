import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/slot_machine.dart';
import '../widgets/roulette.dart';
import '../widgets/aviator.dart';
import '../widgets/mines.dart';

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
              childAspectRatio: 0.78,
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
  final String prompt;
  const _Game(this.name, this.provider, this.emoji, this.colors, this.prompt, {this.jackpot = false});

  String get thumbnail {
    final p = Uri.encodeComponent(prompt);
    final seed = name.hashCode.abs() % 99999;
    return 'https://image.pollinations.ai/prompt/$p?width=400&height=500&seed=$seed&nologo=true&model=flux';
  }
}

const _slotGames = [
  _Game('Sweet Bonanza', 'Pragmatic', '🍭', [Color(0xFFEC407A), Color(0xFF7B1FA2)],
      'casino slot game thumbnail Sweet Bonanza candy lollipops fruits, vibrant pink purple, vertical 2d game art', jackpot: true),
  _Game('Gates of Olympus', 'Pragmatic', '⚡', [Color(0xFF1E88E5), Color(0xFF6A1B9A)],
      'casino slot Gates of Olympus Greek god Zeus lightning, dark blue purple, vertical art'),
  _Game('Big Bass Bonanza', 'Pragmatic', '🎣', [Color(0xFF26A69A), Color(0xFF1565C0)],
      'casino slot Big Bass Bonanza fishing rod giant bass fish, water blue, vertical 2d art'),
  _Game('Wolf Gold', 'Pragmatic', '🐺', [Color(0xFF6D4C41), Color(0xFFFF6F00)],
      'casino slot Wolf Gold native american wolf moon canyon, golden orange, vertical 2d art'),
  _Game('Book of Dead', 'Play\'n GO', '📜', [Color(0xFFFFC107), Color(0xFFE65100)],
      'casino slot Book of Dead Egyptian explorer pyramid, gold yellow, vertical 2d art'),
  _Game('Solar Queen', 'Playson', '☀️', [Color(0xFFFFD700), Color(0xFFE53935)],
      'casino slot Solar Queen ancient Egyptian goddess sun, gold red dramatic, vertical 2d art', jackpot: true),
  _Game('Aztec Gold', 'Playson', '🏛️', [Color(0xFFFFA000), Color(0xFF558B2F)],
      'casino slot Aztec Gold pyramid temple jungle, gold green megaways style, vertical art'),
  _Game('Crystal Crater', 'BGaming', '💎', [Color(0xFF1E88E5), Color(0xFF7B1FA2)],
      'casino slot Crystal Crater shiny gems mountain, blue purple sparkle, vertical 2d art'),
  _Game('Savanna King', 'Booming', '🦁', [Color(0xFFFFA000), Color(0xFF558B2F)],
      'casino slot Savanna King African lion savannah safari, golden green, vertical 2d art'),
  _Game('Captain\'s Bounty', 'NetEnt', '🏴‍☠️', [Color(0xFF6D4C41), Color(0xFF000000)],
      'casino slot Captains Bounty pirate ship treasure chest, dark sea brown, vertical 2d art'),
  _Game('Elvis Frog', 'BGaming', '🐸', [Color(0xFFFFEB3B), Color(0xFF1E1E1E)],
      'casino slot Elvis Frog rock star frog Las Vegas, neon yellow black, vertical 2d art'),
  _Game('Starburst', 'NetEnt', '💎', [Color(0xFF00ACC1), Color(0xFFFF6F00)],
      'casino slot Starburst space cosmic gems neon, dark blue stars, vertical 2d art'),
  _Game('Magical Amazon', 'Booming', '🌳', [Color(0xFF558B2F), Color(0xFFE91E63)],
      'casino slot Magical Amazon warrior queen jungle, vibrant green pink, vertical 2d art'),
  _Game('Book of Nefertiti', 'Reflex', '👑', [Color(0xFFFFD700), Color(0xFF1565C0)],
      'casino slot Book of Nefertiti Egyptian queen pharaoh, gold blue, vertical 2d art'),
  _Game('Aviator', 'Spribe', '✈️', [Color(0xFFE53935), Color(0xFF1E1E1E)],
      'casino crash game Aviator red biplane airplane sky, dark dramatic, vertical 2d art', jackpot: true),
  _Game('JetX', 'SmartSoft', '🚀', [Color(0xFFE53935), Color(0xFF6A1B9A)],
      'casino crash game JetX rocket flying purple sky, neon, vertical 2d art'),
  _Game('Mines', 'Spribe', '💣', [Color(0xFFFFA000), Color(0xFF424242)],
      'casino mines game grid bombs diamonds, dark glowing yellow, vertical 2d art'),
  _Game('Plinko', 'Spribe', '🟡', [Color(0xFF1E88E5), Color(0xFF7B1FA2)],
      'casino Plinko game ball pegs pyramid neon, blue purple, vertical 2d art'),
  _Game('Sugar Rush', 'Pragmatic', '🍬', [Color(0xFFEC407A), Color(0xFFFFA000)],
      'casino slot Sugar Rush colorful candy sweet world, pink orange cute, vertical 2d art'),
  _Game('Fruit Party', 'Pragmatic', '🍓', [Color(0xFFEF5350), Color(0xFF66BB6A)],
      'casino slot Fruit Party fresh juicy fruits cherries grapes, vibrant red green, vertical 2d art'),
];

const _liveCasinoGames = [
  _Game('Lightning Roulette', 'Evolution', '🎯', [Color(0xFFE53935), Color(0xFFFFA000)],
      'live casino Lightning Roulette wheel electric purple background, dramatic, vertical art'),
  _Game('Crazy Time', 'Evolution', '🎪', [Color(0xFFE91E63), Color(0xFF7B1FA2)],
      'live casino Crazy Time TV game show wheel colorful, pink purple festive, vertical art', jackpot: true),
  _Game('Monopoly Live', 'Evolution', '🎲', [Color(0xFF42A5F5), Color(0xFFE53935)],
      'live casino Monopoly Live board game show wheel Mr Monopoly, blue red, vertical art'),
  _Game('Dream Catcher', 'Evolution', '🎡', [Color(0xFF7B1FA2), Color(0xFFE91E63)],
      'live casino Dream Catcher money wheel game show, vibrant purple pink, vertical art'),
  _Game('Speed Baccarat', 'Evolution', '🃏', [Color(0xFF1565C0), Color(0xFF000000)],
      'live casino Speed Baccarat playing cards green table dealer, blue dark, vertical art'),
  _Game('Blackjack VIP', 'Evolution', '♠️', [Color(0xFF2E7D32), Color(0xFF000000)],
      'live casino Blackjack VIP card table green felt elegant, dark luxury, vertical art'),
  _Game('Baccarat First Person', 'Evolution', '👑', [Color(0xFFFFD700), Color(0xFF6D4C41)],
      'live casino Baccarat First Person elegant table luxury, gold dark, vertical art'),
  _Game('Football Studio', 'Evolution', '⚽', [Color(0xFF22B14C), Color(0xFFE53935)],
      'live casino Football Studio game show soccer cards, green field red, vertical art'),
  _Game('Mega Wheel', 'Pragmatic', '🎡', [Color(0xFFE65100), Color(0xFF7B1FA2)],
      'live casino Mega Wheel spinning prize numbers, orange purple, vertical art'),
  _Game('Sweet Bonanza CandyLand', 'Pragmatic', '🍭', [Color(0xFFEC407A), Color(0xFF42A5F5)],
      'live casino CandyLand sweet candy game show host, pink blue, vertical art', jackpot: true),
  _Game('Texas Hold\'em', 'Evolution', '🎴', [Color(0xFF388E3C), Color(0xFF000000)],
      'live casino Texas Holdem poker chips cards table, green dark, vertical art'),
  _Game('Sic Bo', 'Evolution', '🎲', [Color(0xFFE53935), Color(0xFFFFA000)],
      'live casino Sic Bo three dice red gold table, dramatic chinese, vertical art'),
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
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Gradient placeholder (shows while AI image loads or if it fails)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: game.colors,
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(game.emoji,
                    style: TextStyle(fontSize: 80, color: Colors.white.withOpacity(0.4))),
              ),
              // 2. AI-generated game artwork
              Image.network(
                game.thumbnail,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, prog) {
                  if (prog == null) return child;
                  return const SizedBox.shrink();
                },
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
              // 3. Dark overlay at bottom for text readability
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              // 4. Top badges
              Positioned(
                top: 6, left: 6,
                child: Row(
                  children: [
                    if (isLive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.liveRed,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Text('LIVE',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                      ),
                    if (game.jackpot) ...[
                      if (isLive) const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Text('JACKPOT',
                            style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ],
                ),
              ),
              // 5. Bottom text
              Positioned(
                left: 8, right: 8, bottom: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(game.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                        )),
                    Text(game.provider,
                        style: const TextStyle(
                          color: Colors.white70, fontSize: 9,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComing(BuildContext context) {
    final n = game.name.toLowerCase();
    Widget dialog;
    if (n.contains('aviator') || n.contains('jetx') || n.contains('crash')) {
      dialog = AviatorDialog(gameName: game.name);
    } else if (n.contains('mines')) {
      dialog = MinesDialog(gameName: game.name);
    } else if (n.contains('roulette') || n.contains('wheel') || n.contains('crazy time') ||
               n.contains('monopoly') || n.contains('dream catcher') || n.contains('mega')) {
      dialog = RouletteDialog(gameName: game.name);
    } else {
      dialog = SlotMachineDialog(gameName: game.name, emoji: game.emoji, colors: game.colors);
    }
    showDialog(context: context, builder: (_) => dialog);
  }
}
