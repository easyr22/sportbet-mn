import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class WinnersTicker extends StatefulWidget {
  const WinnersTicker({super.key});
  @override
  State<WinnersTicker> createState() => _WinnersTickerState();
}

class _WinnersTickerState extends State<WinnersTicker> with SingleTickerProviderStateMixin {
  late ScrollController _ctl;
  late Timer _timer;
  final _rng = Random();

  static const _names = [
    'easyR22', 'Bat***ar', 'Tem***en', 'Anu***aa', 'Bay***mb',
    'Gan***ag', 'Mun***zay', 'Sar***il', 'Bil***uun', 'Och***bat',
    'Tse***rin', 'Erd***ne', 'Khu***ra', 'Nar***til', 'Dor***rj',
    'Ulz***ai', 'Bol***mb', 'Eni***ee', 'Ari***ne', 'Sar***bb',
  ];
  static const _matches = [
    'Real Madrid - Barcelona', 'Man City - Arsenal', 'Bayern - Dortmund',
    'PSG - Marseille', 'Liverpool - Tottenham', 'Inter - Juventus',
    'NaVi - FaZe Clan', 'T1 - Gen.G', 'G2 - Vitality', 'Cloud9 - Liquid',
    'Lakers - Celtics', 'Warriors - Heat', 'Yankees - Red Sox',
    'Alcaraz - Djokovic', 'Sinner - Medvedev', 'Sweet Bonanza Slot',
    'Aviator Crash', 'Lightning Roulette', 'Mines Game',
  ];
  static const _amounts = [
    '+12,500₮', '+45,000₮', '+87,200₮', '+125,400₮', '+250,000₮',
    '+18,300₮', '+62,800₮', '+340,500₮', '+95,600₮', '+520,000₮',
    '+33,200₮', '+78,400₮', '+1,250,000₮', '+15,800₮', '+225,000₮',
  ];

  late List<_Win> _wins;

  @override
  void initState() {
    super.initState();
    _ctl = ScrollController();
    _wins = List.generate(20, (i) => _genWin());
    // Auto-scroll
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoScroll());
    // Periodically prepend new wins
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      setState(() {
        _wins.insert(0, _genWin());
        if (_wins.length > 30) _wins.removeLast();
      });
    });
  }

  _Win _genWin() {
    return _Win(
      name: _names[_rng.nextInt(_names.length)],
      match: _matches[_rng.nextInt(_matches.length)],
      amount: _amounts[_rng.nextInt(_amounts.length)],
      isBig: _rng.nextDouble() < 0.15,
    );
  }

  void _autoScroll() async {
    while (mounted && _ctl.hasClients) {
      final max = _ctl.position.maxScrollExtent;
      if (max == 0) {
        await Future.delayed(const Duration(milliseconds: 500));
        continue;
      }
      await _ctl.animateTo(max,
          duration: Duration(seconds: (max / 30).round()),
          curve: Curves.linear);
      _ctl.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A2540), Color(0xFF142339), Color(0xFF0A2540)],
        ),
        border: Border(
          top: BorderSide(color: AppColors.accent, width: 1),
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Live label
          Container(
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.liveRed, Color(0xFFB71C1C)],
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.bolt, color: Color(0xFFFFD700), size: 14),
                SizedBox(width: 4),
                Text('ХОЖИЛТУУД',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              ],
            ),
          ),
          // Scrolling list
          Expanded(
            child: ShaderMask(
              shaderCallback: (rect) => const LinearGradient(
                colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
                stops: [0.0, 0.04, 0.96, 1.0],
              ).createShader(rect),
              blendMode: BlendMode.dstIn,
              child: ListView.separated(
                controller: _ctl,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: _wins.length,
                separatorBuilder: (_, __) => Container(width: 1, height: 14, color: AppColors.divider, margin: const EdgeInsets.symmetric(horizontal: 12)),
                itemBuilder: (_, i) {
                  final w = _wins[i];
                  return Center(
                    child: Row(
                      children: [
                        Text('🎉 ', style: TextStyle(fontSize: w.isBig ? 14 : 12)),
                        Text(w.name,
                            style: TextStyle(
                                color: w.isBig ? const Color(0xFFFFD700) : Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                        const Text(' • ',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        Text(w.match,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        const SizedBox(width: 8),
                        Text(w.amount,
                            style: TextStyle(
                                color: w.isBig ? const Color(0xFFFFD700) : AppColors.accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w900)),
                        if (w.isBig) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Text('BIG WIN',
                                style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Win {
  final String name, match, amount;
  final bool isBig;
  const _Win({required this.name, required this.match, required this.amount, this.isBig = false});
}
