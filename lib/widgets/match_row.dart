import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/sport_event.dart';
import '../models/bet_item.dart';
import '../data/bet_provider.dart';

class MatchRow extends StatelessWidget {
  final SportEvent event;

  const MatchRow({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final market = event.markets.isNotEmpty ? event.markets.first : null;

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Material(
        color: AppColors.surface,
        child: InkWell(
          onTap: () {},
          hoverColor: AppColors.surfaceHov,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Time / Live
                SizedBox(
                  width: 62,
                  child: event.isLive
                      ? _LiveBadge(minuteStr: event.minute)
                      : _TimeLabel(time: event.startTime),
                ),
                const SizedBox(width: 8),
                // Teams + score
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TeamLine(
                        name: event.homeTeam,
                        logoUrl: event.homeLogo,
                        score: event.isLive ? event.homeScore : null,
                        winning: event.isLive && event.homeScore > event.awayScore,
                      ),
                      const SizedBox(height: 3),
                      _TeamLine(
                        name: event.awayTeam,
                        logoUrl: event.awayLogo,
                        score: event.isLive ? event.awayScore : null,
                        winning: event.isLive && event.awayScore > event.homeScore,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Odds
                if (market != null)
                  Consumer<BetProvider>(
                    builder: (_, prov, __) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: market.options.take(3).map((opt) {
                        final sel = prov.isSelected(event.id, market.id, opt.label);
                        return _OddsBtn(
                          label: opt.label,
                          odds: opt.odds,
                          selected: sel,
                          onTap: () => prov.toggleBet(BetItem(
                            id: market.id,
                            eventId: event.id,
                            homeTeam: event.homeTeam,
                            awayTeam: event.awayTeam,
                            league: event.league,
                            marketName: market.name,
                            optionLabel: opt.label,
                            odds: opt.odds,
                          )),
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(width: 6),
                // +N markets
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.oddsBtn,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    '+${event.totalMarkets}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Live badge ──────────────────────────────────────────────────────────────

class _LiveBadge extends StatefulWidget {
  final String? minuteStr;
  const _LiveBadge({this.minuteStr});

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: _ctrl,
              child: Container(
                width: 6, height: 6,
                decoration: const BoxDecoration(color: AppColors.liveRed, shape: BoxShape.circle),
              ),
            ),
            const SizedBox(width: 4),
            const Text('LIVE',
                style: TextStyle(
                    color: AppColors.liveRed, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.6)),
          ],
        ),
        if (widget.minuteStr != null && widget.minuteStr!.isNotEmpty)
          Text(widget.minuteStr!,
              style: const TextStyle(color: AppColors.liveRed, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ── Time label ───────────────────────────────────────────────────────────────

class _TimeLabel extends StatelessWidget {
  final DateTime time;
  const _TimeLabel({required this.time});

  @override
  Widget build(BuildContext context) {
    return Text(
      DateFormat('HH:mm').format(time),
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
    );
  }
}

// ── Team line ────────────────────────────────────────────────────────────────

class _TeamLine extends StatelessWidget {
  final String name, logoUrl;
  final int? score;
  final bool winning;

  const _TeamLine({
    required this.name,
    this.logoUrl = '',
    this.score,
    this.winning = false,
  });

  Color _color() {
    const palette = [
      Color(0xFFE53935), Color(0xFF1E88E5), Color(0xFF43A047),
      Color(0xFFE91E63), Color(0xFF8E24AA), Color(0xFFFF7043),
      Color(0xFF00ACC1), Color(0xFFFFB300), Color(0xFF6D4C41),
      Color(0xFF546E7A), Color(0xFF00897B), Color(0xFFD81B60),
    ];
    int h = 0;
    for (final c in name.codeUnits) h = (h * 31 + c) & 0xFFFFFFFF;
    return palette[h % palette.length];
  }

  String _initials() =>
      name.trim().split(' ').take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();

  @override
  Widget build(BuildContext context) {
    final col = _color();
    final ini = _initials();
    return Row(
      children: [
        SizedBox(
          width: 18, height: 18,
          child: logoUrl.isNotEmpty
              ? Image.network(logoUrl, width: 18, height: 18, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _Circle(ini, col, 18))
              : _Circle(ini, col, 18),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              color: winning ? Colors.white : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: winning ? FontWeight.w600 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (score != null)
          Text(
            '$score',
            style: TextStyle(
              color: winning ? AppColors.orange : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}

class _Circle extends StatelessWidget {
  final String initials;
  final Color color;
  final double size;
  const _Circle(this.initials, this.color, this.size);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1),
      ),
      child: Center(
        child: Text(initials,
            style: TextStyle(color: color, fontSize: size * 0.35, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ── Odds button ───────────────────────────────────────────────────────────────

class _OddsBtn extends StatelessWidget {
  final String label;
  final double odds;
  final bool selected;
  final VoidCallback onTap;

  const _OddsBtn({
    required this.label, required this.odds,
    required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 64,
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.orange : AppColors.oddsBtn,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: selected ? AppColors.orange : AppColors.divider),
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(
                    color: selected ? Colors.white : AppColors.textMuted, fontSize: 10)),
            Text(odds.toStringAsFixed(2),
                style: TextStyle(
                    color: selected ? Colors.white : AppColors.orange,
                    fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
