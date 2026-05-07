import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/app_colors.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});
  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  List<Map<String, dynamic>> _results = [];
  bool _loading = true;
  Timer? _timer;

  static String get _base {
    if (kIsWeb) {
      final uri = Uri.base;
      final port = uri.port;
      final showPort = port != 80 && port != 443 && port != 0;
      return '${uri.scheme}://${uri.host}${showPort ? ':$port' : ''}';
    }
    return 'http://localhost:3001';
  }

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _load());
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  Future<void> _load() async {
    try {
      final res = await http.get(Uri.parse('$_base/api/results?limit=200')).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        setState(() {
          _results = List<Map<String, dynamic>>.from(data['results'] ?? []);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Map<String, List<Map<String, dynamic>>> _grouped() {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final r in _results) {
      final k = '${r['countryFlag']}  ${r['country']} — ${r['league']}';
      map.putIfAbsent(k, () => []).add(r);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        color: AppColors.bg,
        child: const Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }
    if (_results.isEmpty) {
      return Container(
        color: AppColors.bg,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.history, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 12),
              const Text('Үр дүн хүлээгдэж байна',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Тоглолтууд дуусахад энд харагдана',
                  style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 12)),
            ],
          ),
        ),
      );
    }

    final groups = _grouped();
    return Container(
      color: AppColors.bg,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Hero
          Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF424242), Color(0xFF1565C0)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.assessment, color: Colors.white, size: 38),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ҮР ДҮН',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                      Text('Сүүлд дууссан ${_results.length} тоглолт',
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('30 сек тутамд шинэчилнэ',
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ],
            ),
          ),
          ...groups.entries.map((e) => _LeagueResults(title: e.key, results: e.value)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _LeagueResults extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> results;
  const _LeagueResults({required this.title, required this.results});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(10, 6, 10, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.blueDark, AppColors.surface],
              begin: Alignment.centerLeft, end: Alignment.centerRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6), topRight: Radius.circular(6),
            ),
            border: const Border(left: BorderSide(color: AppColors.accent, width: 3)),
          ),
          child: Row(children: [
            Expanded(child: Text(title,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(3)),
              child: Text('${results.length}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(6), bottomRight: Radius.circular(6),
            ),
          ),
          child: Column(
            children: results.map((r) => _ResultRow(r: r)).toList(),
          ),
        ),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  final Map<String, dynamic> r;
  const _ResultRow({required this.r});
  @override
  Widget build(BuildContext context) {
    final hs = r['homeScore'] ?? 0;
    final as_ = r['awayScore'] ?? 0;
    final hWin = (hs as num) > (as_ as num);
    final aWin = (as_ as num) > (hs as num);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text('FT',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r['homeTeam'] ?? '?',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: hWin ? Colors.white : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: hWin ? FontWeight.w700 : FontWeight.w400)),
                const SizedBox(height: 3),
                Text(r['awayTeam'] ?? '?',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: aWin ? Colors.white : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: aWin ? FontWeight.w700 : FontWeight.w400)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$hs',
                  style: TextStyle(
                      color: hWin ? AppColors.accent : Colors.white,
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text('$as_',
                  style: TextStyle(
                      color: aWin ? AppColors.accent : Colors.white,
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
