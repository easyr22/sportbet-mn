import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../data/bet_provider.dart';
import '../data/mock_data.dart';
import '../models/sport.dart';
import '../models/sport_event.dart';
import '../widgets/match_card.dart';
import '../widgets/sport_category_row.dart';
import '../widgets/promo_banner.dart';
import '../widgets/bottom_bet_bar.dart';
import 'sport_events_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedSport = 'football';

  @override
  Widget build(BuildContext context) {
    final featured = getFeaturedEvents()
        .where((e) => e.sportId == _selectedSport)
        .toList();
    final today = getMockEvents()
        .where((e) => e.sportId == _selectedSport && !e.isLive)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _AppBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                const SizedBox(height: 12),
                const PromoBanner(),
                const SizedBox(height: 16),
                SportCategoryRow(
                  selectedId: _selectedSport,
                  onSelected: (id) => setState(() => _selectedSport = id),
                ),
                const SizedBox(height: 8),
                _QuickStats(sportId: _selectedSport),
                const SizedBox(height: 12),
                if (featured.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Онцлох тоглолтууд',
                    onMore: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SportEventsScreen(sportId: _selectedSport),
                      ),
                    ),
                  ),
                  ...featured.map((e) => MatchCard(
                        event: e,
                        onTap: () => _openEvent(e),
                      )),
                ],
                if (today.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _SectionHeader(
                    title: 'Өнөөдрийн тоглолтууд',
                    onMore: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SportEventsScreen(sportId: _selectedSport),
                      ),
                    ),
                  ),
                  ...today.map((e) => MatchCard(
                        event: e,
                        onTap: () => _openEvent(e),
                      )),
                ],
                if (featured.isEmpty && today.isEmpty)
                  _EmptyState(sport: _selectedSport),
              ],
            ),
          ),
          const BottomBetBar(),
        ],
      ),
    );
  }

  void _openEvent(SportEvent event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SportEventsScreen(
          sportId: event.sportId,
          highlightEventId: event.id,
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      color: AppColors.surface,
      child: Row(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gradient1, AppColors.gradient2],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'SPORT\nBET',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.black,
                height: 1.2,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'MN',
            style: TextStyle(
              color: AppColors.orange,
              fontSize: 20,
              fontWeight: FontWeight.black,
            ),
          ),
          const Spacer(),
          Consumer<BetProvider>(
            builder: (context, provider, _) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet,
                      color: AppColors.green, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '₮${_formatBalance(provider.balance)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.orange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () => _showDeposit(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
              ),
              child: const Text(
                'Орц',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.textSecondary),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  String _formatBalance(double val) {
    if (val >= 1000000) return '${(val / 1000000).toStringAsFixed(1)}M';
    if (val >= 1000) return '${(val / 1000).toStringAsFixed(0)}K';
    return val.toStringAsFixed(0);
  }

  void _showDeposit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _DepositSheet(),
    );
  }
}

class _DepositSheet extends StatefulWidget {
  const _DepositSheet();

  @override
  State<_DepositSheet> createState() => _DepositSheetState();
}

class _DepositSheetState extends State<_DepositSheet> {
  final amounts = [5000.0, 10000.0, 20000.0, 50000.0, 100000.0];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Дансанд орц нэмэх',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: amounts.map((a) {
              return ElevatedButton(
                onPressed: () {
                  context.read<BetProvider>().deposit(a);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '₮${a.toStringAsFixed(0)} амжилттай нэмэгдлээ!'),
                      backgroundColor: AppColors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.card,
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.orange),
                ),
                child: Text('₮${a.toStringAsFixed(0)}'),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final String sportId;
  const _QuickStats({required this.sportId});

  @override
  Widget build(BuildContext context) {
    final events = getMockEvents().where((e) => e.sportId == sportId).toList();
    final liveCount = events.where((e) => e.isLive).length;
    final upcomingCount = events.where((e) => !e.isLive).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _StatChip(
            icon: Icons.circle,
            iconColor: AppColors.liveRed,
            label: '$liveCount Шууд тоглолт',
          ),
          const SizedBox(width: 8),
          _StatChip(
            icon: Icons.access_time,
            iconColor: AppColors.textSecondary,
            label: '$upcomingCount Удахгүй',
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 10),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onMore;

  const _SectionHeader({required this.title, this.onMore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.orange,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (onMore != null)
            TextButton(
              onPressed: onMore,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
              ),
              child: const Text(
                'Бүгдийг харах',
                style: TextStyle(
                  color: AppColors.orange,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String sport;
  const _EmptyState({required this.sport});

  @override
  Widget build(BuildContext context) {
    final s = allSports.firstWhere((s) => s.id == sport,
        orElse: () => const Sport(
            id: '', name: 'Спорт', emoji: '🏆', eventCount: 0, liveCount: 0));
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Text(s.emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            '${s.name}-ийн тоглолт байхгүй',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
