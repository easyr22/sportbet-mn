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
    '7️⃣7️⃣7️⃣': 50.0,  // jackpot
    '💎💎💎': 25.0,
    '⭐⭐⭐': 15.0,
    '🔔🔔🔔': 10.0,
    '🍉🍉🍉': 8.0,
    '🍇🍇🍇': 6.0,
    '🍊🍊🍊': 5.0,
    '🍋🍋🍋': 4.0,
    '🍒🍒🍒': 3.0,
  };

  final _rng = Random();
  final List<String> _reels = ['🍒', '🍋', '🍊'];
  bool _spinning = false;
  double _stake = 1000;
  double _lastWin = 0;
  String? _resultMsg;
  Color _resultColor = AppColors.accent;

  Future<void> _spin(BuildContext ctx) async {
    final prov = ctx.read<BetProvider>();
    if (_spinning) return;
    if (_stake > prov.balance) {
      setState(() {
        _resultMsg = 'Үлдэгдэл хүрэлцэхгүй!';
        _resultColor = AppColors.liveRed;
      });
      return;
    }
    setState(() {
      _spinning = true; _resultMsg = null; _lastWin = 0;
    });
    prov.deposit(-_stake);

    // Spin animation - rapid symbol changes
    for (int i = 0; i < 20; i++) {
      await Future.delayed(Duration(milliseconds: 60 + i * 8));
      if (!mounted) return;
      setState(() {
        _reels[0] = _symbols[_rng.nextInt(_symbols.length)];
        _reels[1] = _symbols[_rng.nextInt(_symbols.length)];
        _reels[2] = _symbols[_rng.nextInt(_symbols.length)];
      });
    }

    // Final result with weighted random (low chance of jackpot)
    final r = _rng.nextDouble();
    if (r < 0.005) { // jackpot 0.5%
      _reels[0]=_reels[1]=_reels[2]='7️⃣';
    } else if (r < 0.02) { // diamond 1.5%
      _reels[0]=_reels[1]=_reels[2]='💎';
    } else if (r < 0.05) { // star 3%
      _reels[0]=_reels[1]=_reels[2]='⭐';
    } else if (r < 0.10) { // bell 5%
      _reels[0]=_reels[1]=_reels[2]='🔔';
    } else if (r < 0.18) { // any matching fruit 8%
      final f = ['🍒','🍋','🍊','🍇','🍉'][_rng.nextInt(5)];
      _reels[0]=_reels[1]=_reels[2]=f;
    } else {
      // mostly mixed (loss)
      _reels[0] = _symbols[_rng.nextInt(_symbols.length)];
      _reels[1] = _symbols[_rng.nextInt(_symbols.length)];
      _reels[2] = _symbols[_rng.nextInt(_symbols.length)];
    }

    setState(() {});
    await Future.delayed(const Duration(milliseconds: 200));

    final combo = _reels.join();
    final mul = _payouts[combo];
    if (mul != null) {
      final win = _stake * mul;
      _lastWin = win;
      prov.deposit(win);
      setState(() {
        _spinning = false;
        _resultMsg = '🎉 ХОЖИЛТ! ×${mul.toStringAsFixed(0)} = ${win.toStringAsFixed(0)}₮';
        _resultColor = mul >= 25 ? const Color(0xFFFFD700) : AppColors.accent;
      });
    } else {
      setState(() {
        _spinning = false;
        _resultMsg = 'Дахин оролдоорой';
        _resultColor = AppColors.textSecondary;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: widget.colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(widget.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(widget.gameName,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Reels
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _reels.map((s) => AnimatedContainer(
                  duration: const Duration(milliseconds: 80),
                  width: 80, height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(s, style: const TextStyle(fontSize: 56)),
                )).toList(),
              ),
            ),
            const SizedBox(height: 14),
            if (_resultMsg != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _resultColor.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: _resultColor),
                ),
                child: Text(_resultMsg!,
                    style: TextStyle(color: _resultColor, fontSize: 14, fontWeight: FontWeight.w800)),
              ),
            const SizedBox(height: 14),
            Consumer<BetProvider>(
              builder: (_, p, __) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('💰 ₮${p.balance.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                  Text('Бооцоо: ${_stake.toStringAsFixed(0)}₮',
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Stake selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [500, 1000, 5000, 10000].map((v) => InkWell(
                onTap: _spinning ? null : () => setState(() => _stake = v.toDouble()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _stake == v.toDouble() ? Colors.white : Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('${v}₮',
                      style: TextStyle(
                          color: _stake == v.toDouble() ? Colors.black : Colors.white,
                          fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 14),
            Builder(
              builder: (ctx) => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _spinning ? null : () => _spin(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    disabledBackgroundColor: AppColors.surfaceHov,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(_spinning ? 'ЭРГЭЖ БАЙНА...' : '🎰 SPIN',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('7️⃣7️⃣7️⃣ = ×50  •  💎💎💎 = ×25  •  ⭐⭐⭐ = ×15',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
