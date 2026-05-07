import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../data/bet_provider.dart';

class SlotMachineDialog extends StatefulWidget {
  final String gameName;
  final String emoji;
  final List<Color> colors;
  const SlotMachineDialog({
    super.key, required this.gameName, required this.emoji, required this.colors,
  });

  @override
  State<SlotMachineDialog> createState() => _SlotMachineDialogState();
}

class _SlotMachineDialogState extends State<SlotMachineDialog> with TickerProviderStateMixin {
  static const _symbols = ['🍒','🍋','🍊','🍇','🍉','⭐','💎','7️⃣','🔔'];
  static const _payouts = {
    '7️⃣7️⃣7️⃣7️⃣7️⃣': 250.0,  // 5x mega jackpot
    '7️⃣7️⃣7️⃣': 50.0,
    '💎💎💎💎💎': 100.0,
    '💎💎💎': 25.0,
    '⭐⭐⭐⭐⭐': 80.0,
    '⭐⭐⭐': 15.0,
    '🔔🔔🔔🔔🔔': 60.0,
    '🔔🔔🔔': 10.0,
    '🍉🍉🍉': 8.0,
    '🍇🍇🍇': 6.0,
    '🍊🍊🍊': 5.0,
    '🍋🍋🍋': 4.0,
    '🍒🍒🍒': 3.0,
  };

  final _rng = Random();
  final List<List<String>> _reels = [
    ['🍒', '🍋', '🍊'],
    ['🍇', '🍉', '🍒'],
    ['⭐', '🔔', '💎'],
    ['7️⃣', '🍒', '🍋'],
    ['🍊', '🍇', '⭐'],
  ]; // 5 reels x 3 rows
  bool _spinning = false;
  double _stake = 1000;
  String? _resultMsg;
  Color _resultColor = AppColors.accent;
  late AnimationController _shineCtl;

  @override
  void initState() {
    super.initState();
    _shineCtl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() { _shineCtl.dispose(); super.dispose(); }

  String _rs() => _symbols[_rng.nextInt(_symbols.length)];

  Future<void> _spin(BuildContext ctx) async {
    final prov = ctx.read<BetProvider>();
    if (_spinning) return;
    if (_stake > prov.balance) {
      setState(() {
        _resultMsg = '⚠️  Үлдэгдэл хүрэлцэхгүй!';
        _resultColor = AppColors.liveRed;
      });
      return;
    }
    setState(() { _spinning = true; _resultMsg = null; });
    prov.deposit(-_stake);

    // Stagger 5 reels
    for (int reel = 0; reel < 5; reel++) {
      Future(() async {
        for (int i = 0; i < 12 + reel * 3; i++) {
          await Future.delayed(const Duration(milliseconds: 60));
          if (!mounted) return;
          setState(() {
            _reels[reel] = [_rs(), _rs(), _rs()];
          });
        }
      });
    }
    await Future.delayed(const Duration(milliseconds: 60 * 27 + 200));
    if (!mounted) return;

    // Final result with weighted random
    final r = _rng.nextDouble();
    String middle;
    if (r < 0.002) { middle = '7️⃣7️⃣7️⃣7️⃣7️⃣'; }       // 0.2% mega jackpot
    else if (r < 0.005) { middle = '💎💎💎💎💎'; }
    else if (r < 0.012) { middle = '⭐⭐⭐⭐⭐'; }
    else if (r < 0.020) { middle = '🔔🔔🔔🔔🔔'; }
    else if (r < 0.035) { middle = '7️⃣7️⃣7️⃣${_rs()}${_rs()}'; }
    else if (r < 0.055) { middle = '💎💎💎${_rs()}${_rs()}'; }
    else if (r < 0.085) { middle = '⭐⭐⭐${_rs()}${_rs()}'; }
    else if (r < 0.13)  { middle = '🔔🔔🔔${_rs()}${_rs()}'; }
    else if (r < 0.22) {
      final f = ['🍒','🍋','🍊','🍇','🍉'][_rng.nextInt(5)];
      middle = '$f$f$f${_rs()}${_rs()}';
    } else {
      middle = List.generate(5, (_) => _rs()).join();
    }
    // split middle row across 5 reels (each emoji might be 1-2 chars)
    final mids = _splitToFive(middle);
    setState(() {
      for (int i = 0; i < 5; i++) {
        _reels[i] = [_rs(), mids[i], _rs()];
      }
    });
    await Future.delayed(const Duration(milliseconds: 300));

    // Calculate win — match left-to-right consecutive in middle row
    final mid = mids.join();
    double mul = 0;
    String? combo;
    // Check 5-of-a-kind first
    for (int n = 5; n >= 3; n--) {
      final test = mids.take(n).join();
      if (_payouts.containsKey(test) && mids.take(n).toSet().length == 1) {
        mul = _payouts[test]!; combo = test; break;
      }
    }

    if (mul > 0) {
      final win = _stake * mul;
      prov.deposit(win);
      setState(() {
        _spinning = false;
        _resultMsg = mul >= 50
            ? '🎉🎉 БОЛЗОЛТ! $combo  ×${mul.toStringAsFixed(0)}  =  +${win.toStringAsFixed(0)}₮'
            : '🎉 ХОЖЛОО! $combo  ×${mul.toStringAsFixed(0)}  =  +${win.toStringAsFixed(0)}₮';
        _resultColor = mul >= 50 ? const Color(0xFFFFD700) : AppColors.accent;
      });
    } else {
      setState(() {
        _spinning = false;
        _resultMsg = 'Дахин оролдоорой';
        _resultColor = AppColors.textSecondary;
      });
    }
  }

  // Split combo string to 5 single-emoji parts (handles compound emojis like 7️⃣)
  List<String> _splitToFive(String s) {
    final result = <String>[];
    final runes = s.runes.toList();
    int i = 0;
    while (i < runes.length && result.length < 5) {
      final c = runes[i];
      String emoji = String.fromCharCode(c);
      // Combine with following modifiers (variation selectors, ZWJ, keycap)
      while (i + 1 < runes.length) {
        final n = runes[i+1];
        if (n == 0xFE0F || n == 0x200D || n == 0x20E3 || (n >= 0xD800 && n <= 0xDFFF) || (n >= 0x1F1E6 && n <= 0x1F1FF)) {
          emoji += String.fromCharCode(n);
          i++;
        } else if (n == 0x0030 + 0x20E3 - 0x20E3) {
          break;
        } else { break; }
      }
      // Handle keycap emojis (e.g. 7️⃣ = 0037 FE0F 20E3)
      if (i + 2 < runes.length && runes[i+1] == 0xFE0F && runes[i+2] == 0x20E3) {
        emoji += '️⃣';
        i += 2;
      }
      result.add(emoji);
      i++;
    }
    while (result.length < 5) { result.add(_rs()); }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(8),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540),
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [widget.colors.first, widget.colors.last, Colors.black],
            stops: const [0.0, 0.55, 1.0],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: widget.colors.first.withOpacity(0.6), blurRadius: 30, spreadRadius: 4),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              // Animated shine
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _shineCtl,
                  builder: (_, __) => Transform.translate(
                    offset: Offset(_shineCtl.value * 600 - 300, 0),
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white.withOpacity(0), Colors.white.withOpacity(0.15), Colors.white.withOpacity(0)],
                          begin: Alignment.centerLeft, end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Text(widget.emoji, style: const TextStyle(fontSize: 26)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.gameName,
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900,
                                      shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
                              const Text('20 PAY LINES',
                                  style: TextStyle(color: Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Reels — 5x3 grid
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFFD700), width: 3),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.3), blurRadius: 15, spreadRadius: 1),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(5, (i) => _Reel(symbols: _reels[i])),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_resultMsg != null)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: _resultColor.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _resultColor, width: 2),
                          boxShadow: [BoxShadow(color: _resultColor.withOpacity(0.4), blurRadius: 10)],
                        ),
                        child: Text(_resultMsg!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _resultColor, fontSize: 13, fontWeight: FontWeight.w800)),
                      ),
                    const SizedBox(height: 12),
                    // Balance + bet info
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Consumer<BetProvider>(
                        builder: (_, p, __) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('БАЛАНС', style: TextStyle(color: Colors.white60, fontSize: 9, letterSpacing: 1)),
                                Text('₮${p.balance.toStringAsFixed(0)}',
                                    style: const TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.w900)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('БООЦОО', style: TextStyle(color: Colors.white60, fontSize: 9, letterSpacing: 1)),
                                Text('₮${_stake.toStringAsFixed(0)}',
                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Stake selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [500, 1000, 5000, 10000, 50000].map((v) => InkWell(
                        onTap: _spinning ? null : () => setState(() => _stake = v.toDouble()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: _stake == v.toDouble() ? const Color(0xFFFFD700) : Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('${v}₮',
                              style: TextStyle(
                                  color: _stake == v.toDouble() ? Colors.black : Colors.white,
                                  fontSize: 11, fontWeight: FontWeight.w800)),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 12),
                    Builder(
                      builder: (ctx) => SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _spinning ? null : () => _spin(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            disabledBackgroundColor: AppColors.surfaceHov,
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_spinning)
                                const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                              else
                                const Text('🎰  ', style: TextStyle(fontSize: 22)),
                              const SizedBox(width: 6),
                              Text(_spinning ? '  ЭРГЭЖ БАЙНА' : 'SPIN',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        _PaytableChip('7️⃣×5', '×250', Color(0xFFFFD700)),
                        _PaytableChip('💎×5', '×100', Color(0xFF42A5F5)),
                        _PaytableChip('⭐×5', '×80', Color(0xFFFFA000)),
                        _PaytableChip('🔔×5', '×60', Color(0xFFE91E63)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Reel extends StatelessWidget {
  final List<String> symbols;
  const _Reel({required this.symbols});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final isMid = i == 1;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: const EdgeInsets.all(2),
          width: 56, height: 56,
          decoration: BoxDecoration(
            gradient: isMid
                ? const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFE0E0E0)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                : LinearGradient(colors: [Colors.white.withOpacity(0.85), Colors.white.withOpacity(0.55)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isMid ? const Color(0xFFFFD700) : Colors.white24, width: isMid ? 2 : 1),
            boxShadow: isMid ? [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.4), blurRadius: 8)] : [],
          ),
          alignment: Alignment.center,
          child: Text(symbols[i], style: const TextStyle(fontSize: 36)),
        );
      }),
    );
  }
}

class _PaytableChip extends StatelessWidget {
  final String label, mult;
  final Color color;
  const _PaytableChip(this.label, this.mult, this.color);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
        Text(mult, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
