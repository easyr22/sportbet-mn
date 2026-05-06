import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/sport_event.dart';
import '../models/bet_item.dart';
import '../data/bet_provider.dart';

class MatchCard extends StatelessWidget {
  final SportEvent event;
  final VoidCallback? onTap;

  const MatchCard({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    final mainMarket = event.markets.isNotEmpty ? event.markets.first : null;
    final timeStr = event.isLive
        ? null
        : DateFormat('HH:mm').format(event.startTime);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
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
                    _LiveBadge(minute: event.minute)
                  else
                    Text(
                      timeStr ?? '',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      '+${event.totalMarkets}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Teams & Score
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TeamRow(
                          name: event.homeTeam,
                          logoUrl: event.homeLogo,
                          score: event.isLive ? event.homeScore : null,
                          isWinning: event.isLive &&
                              event.homeScore > event.awayScore,
                        ),
                        const SizedBox(height: 8),
                        _TeamRow(
                          name: event.awayTeam,
                          logoUrl: event.awayLogo,
                          score: event.isLive ? event.awayScore : null,
                          isWinning: event.isLive &&
                              event.awayScore > event.homeScore,
                        ),
                      ],
                    ),
                  ),
                  if (event.isLive && event.period != null)
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.liveRed.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            event.period!,
                            style: const TextStyle(
                              color: AppColors.liveRed,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Odds
            if (mainMarket != null)
              Padding(
                padding:
                    const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                child: _OddsRow(event: event, market: mainMarket),
              ),
          ],
        ),
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  final String name;
  final String logoUrl;
  final int? score;
  final bool isWinning;

  const _TeamRow({
    required this.name,
    this.logoUrl = '',
    this.score,
    this.isWinning = false,
  });

  Color _teamColor() {
    const colors = [
      Color(0xFFE53935), Color(0xFF1E88E5), Color(0xFF43A047),
      Color(0xFFE91E63), Color(0xFF8E24AA), Color(0xFFFF7043),
      Color(0xFF00ACC1), Color(0xFFFFB300), Color(0xFF6D4C41),
      Color(0xFF546E7A), Color(0xFF00897B), Color(0xFFD81B60),
    ];
    int hash = 0;
    for (final c in name.codeUnits) hash = (hash * 31 + c) & 0xFFFFFFFF;
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _teamColor();
    final initials = name.trim().split(' ').take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Row(
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: logoUrl.isNotEmpty
              ? Image.network(
                  logoUrl,
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _InitialsAvatar(
                    initials: initials,
                    color: color,
                  ),
                )
              : _InitialsAvatar(initials: initials, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              color: isWinning ? Colors.white : AppColors.textSecondary,
              fontSize: 13,
              fontWeight:
                  isWinning ? FontWeight.bold : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (score != null)
          Text(
            '$score',
            style: TextStyle(
              color: isWinning ? AppColors.orange : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}

class _OddsRow extends StatelessWidget {
  final SportEvent event;
  final BetMarket market;

  const _OddsRow({required this.event, required this.market});

  @override
  Widget build(BuildContext context) {
    return Consumer<BetProvider>(
      builder: (context, provider, _) {
        return Row(
          children: market.options.map((option) {
            final selected = provider.isSelected(
                event.id, market.id, option.label);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _OddsButton(
                  label: option.label,
                  odds: option.odds,
                  isSelected: selected,
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
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _OddsButton extends StatelessWidget {
  final String label;
  final double odds;
  final bool isSelected;
  final VoidCallback onTap;

  const _OddsButton({
    required this.label,
    required this.odds,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.orange : AppColors.cardLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.orange : AppColors.divider,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              odds.toStringAsFixed(2),
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.orange,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String initials;
  final Color color;

  const _InitialsAvatar({required this.initials, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _LiveBadge extends StatefulWidget {
  final String? minute;
  const _LiveBadge({this.minute});

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
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
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.liveRed,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
