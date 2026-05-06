import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../data/mock_data.dart';
import '../data/bet_provider.dart';
import '../models/sport.dart';
import '../models/sport_event.dart';
import '../models/bet_item.dart';
import '../widgets/bottom_bet_bar.dart';

class SportEventsScreen extends StatefulWidget {
  final String sportId;
  final String? highlightEventId;

  const SportEventsScreen({
    super.key,
    required this.sportId,
    this.highlightEventId,
  });

  @override
  State<SportEventsScreen> createState() => _SportEventsScreenState();
}

class _SportEventsScreenState extends State<SportEventsScreen> {
  String? _expandedEventId;

  @override
  void initState() {
    super.initState();
    _expandedEventId = widget.highlightEventId;
  }

  @override
  Widget build(BuildContext context) {
    final sport = allSports.firstWhere(
      (s) => s.id == widget.sportId,
      orElse: () => const Sport(
          id: '', name: 'Спорт', emoji: '🏆', eventCount: 0, liveCount: 0),
    );
    final events = getEventsBySport(widget.sportId);
    final liveEvents = events.where((e) => e.isLive).toList();
    final upcomingEvents = events.where((e) => !e.isLive).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(sport.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              sport.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Consumer<BetProvider>(
            builder: (context, provider, _) {
              if (provider.betCount == 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/betslip'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.receipt_long,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${provider.betCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                if (liveEvents.isNotEmpty) ...[
                  _SectionLabel(
                    label: '🔴  ШУУД ТОГЛОЛТУУД',
                    color: AppColors.liveRed,
                    count: liveEvents.length,
                  ),
                  ...liveEvents.map((e) => _EventTile(
                        event: e,
                        isExpanded: _expandedEventId == e.id,
                        onToggle: () => setState(() {
                          _expandedEventId =
                              _expandedEventId == e.id ? null : e.id;
                        }),
                      )),
                ],
                if (upcomingEvents.isNotEmpty) ...[
                  _SectionLabel(
                    label: '🕐  УДАХГҮЙ ТОГЛОЛТУУД',
                    color: AppColors.textSecondary,
                    count: upcomingEvents.length,
                  ),
                  ...upcomingEvents.map((e) => _EventTile(
                        event: e,
                        isExpanded: _expandedEventId == e.id,
                        onToggle: () => setState(() {
                          _expandedEventId =
                              _expandedEventId == e.id ? null : e.id;
                        }),
                      )),
                ],
              ],
            ),
          ),
          const BottomBetBar(),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  final int count;

  const _SectionLabel({
    required this.label,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: TextStyle(color: color, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final SportEvent event;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _EventTile({
    required this.event,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? AppColors.orange.withOpacity(0.5) : AppColors.divider,
        ),
      ),
      child: Column(
        children: [
          // Header row
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${event.countryFlag} ${event.league}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      if (event.isLive)
                        _LiveIndicator(minute: event.minute)
                      else
                        Text(
                          _formatTime(event.startTime),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      const SizedBox(width: 6),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _TeamRow(
                              name: event.homeTeam,
                              score: event.isLive ? event.homeScore : null,
                              isWinning: event.isLive &&
                                  event.homeScore > event.awayScore,
                            ),
                            const SizedBox(height: 6),
                            _TeamRow(
                              name: event.awayTeam,
                              score: event.isLive ? event.awayScore : null,
                              isWinning: event.isLive &&
                                  event.awayScore > event.homeScore,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+${event.totalMarkets}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Quick 1X2 odds always visible
          if (event.markets.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: _MarketRow(event: event, market: event.markets.first),
            ),

          // Expanded markets
          if (isExpanded)
            ...event.markets.skip(1).map((market) => Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          market.name,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _MarketRow(event: event, market: market),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _TeamRow extends StatelessWidget {
  final String name;
  final int? score;
  final bool isWinning;

  const _TeamRow({required this.name, this.score, this.isWinning = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              color: isWinning ? Colors.white : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: isWinning ? FontWeight.bold : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (score != null)
          Text(
            '$score',
            style: TextStyle(
              color: isWinning ? AppColors.orange : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}

class _MarketRow extends StatelessWidget {
  final SportEvent event;
  final BetMarket market;

  const _MarketRow({required this.event, required this.market});

  @override
  Widget build(BuildContext context) {
    return Consumer<BetProvider>(
      builder: (context, provider, _) {
        return Row(
          children: market.options.map((option) {
            final selected =
                provider.isSelected(event.id, market.id, option.label);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: GestureDetector(
                  onTap: () {
                    provider.toggleBet(BetItem(
                      id: market.id,
                      eventId: event.id,
                      homeTeam: event.homeTeam,
                      awayTeam: event.awayTeam,
                      league: event.league,
                      marketName: market.name,
                      optionLabel: option.label,
                      odds: option.odds,
                    ));
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.orange
                          : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected
                            ? AppColors.orange
                            : AppColors.divider,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          option.label,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          option.odds.toStringAsFixed(2),
                          style: TextStyle(
                            color:
                                selected ? Colors.white : AppColors.orange,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _LiveIndicator extends StatefulWidget {
  final String? minute;
  const _LiveIndicator({this.minute});

  @override
  State<_LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<_LiveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.minute != null)
          Text(
            "${widget.minute}'",
            style: const TextStyle(
              color: AppColors.liveRed,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        const SizedBox(width: 4),
        FadeTransition(
          opacity: _ctrl,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.liveRed,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 3),
        const Text(
          'LIVE',
          style: TextStyle(
            color: AppColors.liveRed,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
