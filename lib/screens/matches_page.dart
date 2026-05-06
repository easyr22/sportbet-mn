import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/sport_event.dart';
import '../services/api_service.dart';
import '../widgets/match_row.dart';
import '../widgets/hero_banner.dart';

class MatchesPage extends StatefulWidget {
  final String sportFilter;
  final bool liveOnly;

  const MatchesPage({super.key, required this.sportFilter, required this.liveOnly});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  List<SportEvent> _events = [];
  bool _loading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _load());
  }

  @override
  void didUpdateWidget(MatchesPage old) {
    super.didUpdateWidget(old);
    if (old.sportFilter != widget.sportFilter || old.liveOnly != widget.liveOnly) {
      setState(() => _loading = true);
      _load();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final List<SportEvent> events;
    if (widget.liveOnly) {
      events = await ApiService.fetchLiveEvents();
    } else {
      final sportId = widget.sportFilter == 'all' ? null : widget.sportFilter;
      events = await ApiService.fetchAllEvents(sportId: sportId);
    }
    if (mounted) {
      setState(() {
        _events = events;
        _loading = false;
      });
    }
  }

  // Group events by "flag country – league"
  Map<String, List<SportEvent>> _grouped() {
    final map = <String, List<SportEvent>>{};
    for (final e in _events) {
      final k = '${e.countryFlag}  ${e.country} — ${e.league}';
      map.putIfAbsent(k, () => []).add(e);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.orange));
    }

    if (_events.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.sports_soccer_outlined, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            widget.liveOnly ? 'Одоо лайв тоглолт байхгүй байна' : 'Тоглолт олдсонгүй',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ]),
      );
    }

    final groups = _grouped();

    return RefreshIndicator(
      color: AppColors.orange,
      backgroundColor: AppColors.surface,
      onRefresh: _load,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: groups.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) return const HeroBanner();
          final key = groups.keys.elementAt(i - 1);
          return _LeagueBlock(title: key, events: groups[key]!);
        },
      ),
    );
  }
}

// ── League block (collapsible) ────────────────────────────────────────────────

class _LeagueBlock extends StatefulWidget {
  final String title;
  final List<SportEvent> events;
  const _LeagueBlock({required this.title, required this.events});

  @override
  State<_LeagueBlock> createState() => _LeagueBlockState();
}

class _LeagueBlockState extends State<_LeagueBlock> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // League header row
      InkWell(
        onTap: () => setState(() => _open = !_open),
        child: Container(
          margin: const EdgeInsets.fromLTRB(10, 6, 10, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.blueDark, AppColors.surface],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            border: const Border(left: BorderSide(color: AppColors.accent, width: 3)),
          ),
          child: Row(children: [
            Expanded(
              child: Text(widget.title,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${widget.events.length}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
            ),
            const SizedBox(width: 6),
            Icon(_open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 15, color: AppColors.textMuted),
          ]),
        ),
      ),
      // Odds column headers (1 / X / 2)
      if (_open)
        Container(
          padding: const EdgeInsets.only(right: 12, top: 3, bottom: 3),
          color: AppColors.bg,
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            _hdr('1', 64), const SizedBox(width: 4),
            _hdr('X', 64), const SizedBox(width: 4),
            _hdr('2', 64), const SizedBox(width: 10),
            _hdr('+мкт', 38),
          ]),
        ),
      if (_open) ...widget.events.map((e) => MatchRow(event: e)),
    ]);
  }

  Widget _hdr(String t, double w) {
    return SizedBox(
      width: w,
      child: Center(
        child: Text(t,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      ),
    );
  }
}
