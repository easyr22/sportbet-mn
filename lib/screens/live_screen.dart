import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/app_colors.dart';
import '../data/mock_data.dart';
import '../models/sport.dart';
import '../models/sport_event.dart';
import '../services/api_service.dart';
import '../widgets/match_card.dart';
import '../widgets/bottom_bet_bar.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  String _selectedSport = 'all';
  late Timer _timer;
  List<SportEvent> _liveEvents = [];
  bool _loading = true;
  bool _fromBackend = false;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _fetchEvents();
    });
  }

  Future<void> _fetchEvents() async {
    final events = await ApiService.fetchLiveEvents();
    if (mounted) {
      setState(() {
        if (events.isNotEmpty) {
          _liveEvents = events;
          _fromBackend = true;
        } else {
          _liveEvents = getLiveEvents();
          _fromBackend = false;
        }
        _loading = false;
        _lastUpdated = DateTime.now();
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  List<SportEvent> get _filtered {
    if (_selectedSport == 'all') return _liveEvents;
    return _liveEvents.where((e) => e.sportId == _selectedSport).toList();
  }

  List<String> get _availableSports {
    final ids = _liveEvents.map((e) => e.sportId).toSet().toList();
    return ['all', ...ids];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _LiveHeader(
            liveCount: _liveEvents.length,
            fromBackend: _fromBackend,
            lastUpdated: _lastUpdated,
            onRefresh: _fetchEvents,
          ),
          _SportFilter(
            sports: _availableSports,
            selected: _selectedSport,
            onSelected: (s) => setState(() => _selectedSport = s),
          ),
          Expanded(
            child: _loading
                ? const _LoadingShimmer()
                : _filtered.isEmpty
                    ? const _NoLiveGames()
                    : RefreshIndicator(
                        onRefresh: _fetchEvents,
                        color: AppColors.orange,
                        backgroundColor: AppColors.surface,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: _filtered.length,
                          itemBuilder: (context, i) => MatchCard(
                            event: _filtered[i],
                          ),
                        ),
                      ),
          ),
          const BottomBetBar(),
        ],
      ),
    );
  }
}

class _LiveHeader extends StatelessWidget {
  final int liveCount;
  final bool fromBackend;
  final DateTime? lastUpdated;
  final VoidCallback onRefresh;

  const _LiveHeader({
    required this.liveCount,
    required this.fromBackend,
    required this.lastUpdated,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 14,
      ),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PulseDot(),
              const SizedBox(width: 8),
              const Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.liveRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$liveCount тоглолт',
                  style: const TextStyle(
                    color: AppColors.liveRed,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              if (fromBackend)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '● Live',
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onRefresh,
                child: const Icon(Icons.refresh,
                    color: AppColors.textSecondary, size: 20),
              ),
            ],
          ),
          if (lastUpdated != null) ...[
            const SizedBox(height: 4),
            Text(
              'Шинэчлэгдсэн: ${_timeAgo(lastUpdated!)}',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt).inSeconds;
    if (diff < 60) return '$diff секундын өмнө';
    return '${diff ~/ 60} минутын өмнө';
  }
}

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
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
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: AppColors.liveRed,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _SportFilter extends StatelessWidget {
  final List<String> sports;
  final String selected;
  final ValueChanged<String> onSelected;

  const _SportFilter({
    required this.sports,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: AppColors.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: sports.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final sportId = sports[i];
          final isSelected = sportId == selected;
          final sport = sportId == 'all'
              ? null
              : allSports.firstWhere((s) => s.id == sportId,
                  orElse: () => const Sport(
                      id: '', name: 'Бусад', emoji: '🏆',
                      eventCount: 0, liveCount: 0));

          return GestureDetector(
            onTap: () => onSelected(sportId),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.orange : AppColors.card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  sportId == 'all'
                      ? '🌐 Бүгд'
                      : '${sport?.emoji ?? '🏆'} ${sport?.name ?? sportId}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LoadingShimmer extends StatefulWidget {
  const _LoadingShimmer();

  @override
  State<_LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<_LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.card.withOpacity(_anim.value),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _NoLiveGames extends StatelessWidget {
  const _NoLiveGames();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🔴', style: TextStyle(fontSize: 48)),
          SizedBox(height: 16),
          Text(
            'Одоо шууд тоглолт байхгүй',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
          SizedBox(height: 8),
          Text(
            'Удахгүй эхлэх тоглолтуудыг\nНүүр хуудаснаас харна уу',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
