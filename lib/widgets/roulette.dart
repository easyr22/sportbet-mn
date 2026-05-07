import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../data/bet_provider.dart';

class RouletteDialog extends StatefulWidget {
  final String gameName;
  const RouletteDialog({super.key, required this.gameName});
  @override
  State<RouletteDialog> createState() => _RouletteDialogState();
}

class _RouletteDialogState extends State<RouletteDialog> with SingleTickerProviderStateMixin {
  late AnimationController _ctl;
  final _rng = Random();
  int? _result;
  String _bet = 'red'; // red, black, even, odd, low (1-18), high (19-36)
  double _stake = 1000;
  String? _msg;
  Color _msgColor = AppColors.accent;
  bool _spinning = false;

  static const _redNumbers = {1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36};

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: const Duration(seconds: 3));
  }

  @override
  void dispose() { _ctl.dispose(); super.dispose(); }

  Color _numberColor(int n) {
    if (n == 0) return const Color(0xFF22B14C);
    return _redNumbers.contains(n) ? const Color(0xFFE53935) : const Color(0xFF1A1A1A);
  }

  bool _isWin(int n) {
    if (n == 0) return _bet == '0';
    switch (_bet) {
      case 'red':  return _redNumbers.contains(n);
      case 'black': return !_redNumbers.contains(n);
      case 'even': return n % 2 == 0;
      case 'odd':  return n % 2 == 1;
      case 'low':  return n >= 1 && n <= 18;
      case 'high': return n >= 19 && n <= 36;
    }
    return false;
  }

  Future<void> _spin(BuildContext ctx) async {
    if (_spinning) return;
    final prov = ctx.read<BetProvider>();
    if (_stake > prov.balance) {
      setState(() { _msg = 'Үлдэгдэл хүрэлцэхгүй'; _msgColor = AppColors.liveRed; });
      return;
    }
    setState(() { _spinning = true; _msg = null; });
    prov.deposit(-_stake);

    final n = _rng.nextInt(37);
    _ctl.reset();
    _ctl.forward();
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _result = n;
      _spinning = false;
      if (_isWin(n)) {
        final win = _stake * 2;
        prov.deposit(win);
        _msg = '🎉 $n ${_redNumbers.contains(n) ? "RED" : n==0 ? "GREEN" : "BLACK"} — Хожлоо! +${win.toStringAsFixed(0)}₮';
        _msgColor = AppColors.accent;
      } else {
        _msg = '$n ${_redNumbers.contains(n) ? "RED" : n==0 ? "GREEN" : "BLACK"} — Алдсан';
        _msgColor = AppColors.liveRed;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              const Text('🎯', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(child: Text(widget.gameName,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800))),
              IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
            ]),
            const SizedBox(height: 8),
            // Wheel
            Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFF424242), Color(0xFF1A1A1A)],
                ),
                border: Border.all(color: const Color(0xFFFFD700), width: 4),
              ),
              child: Center(
                child: AnimatedBuilder(
                  animation: _ctl,
                  builder: (_, __) => Transform.rotate(
                    angle: _ctl.value * 8 * pi,
                    child: Container(
                      width: 160, height: 160,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(colors: [
                          Color(0xFFE53935), Color(0xFF1A1A1A),
                          Color(0xFFE53935), Color(0xFF1A1A1A),
                          Color(0xFFE53935), Color(0xFF1A1A1A),
                          Color(0xFFE53935), Color(0xFF1A1A1A),
                          Color(0xFF22B14C), Color(0xFFE53935),
                          Color(0xFF1A1A1A), Color(0xFFE53935),
                          Color(0xFF1A1A1A),
                        ]),
                      ),
                      child: _result != null && !_spinning
                          ? Center(
                              child: Container(
                                width: 60, height: 60,
                                decoration: BoxDecoration(
                                  color: _numberColor(_result!),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                ),
                                alignment: Alignment.center,
                                child: Text('$_result',
                                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_msg != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _msgColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: _msgColor),
                ),
                child: Text(_msg!, style: TextStyle(color: _msgColor, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            const SizedBox(height: 12),
            const Text('Сонголт', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: [
                _bt('red', 'УЛААН', const Color(0xFFE53935)),
                _bt('black', 'ХАР', const Color(0xFF1A1A1A)),
                _bt('even', '2,4,6...', AppColors.surfaceHov),
                _bt('odd', '1,3,5...', AppColors.surfaceHov),
                _bt('low', '1-18', AppColors.surfaceHov),
                _bt('high', '19-36', AppColors.surfaceHov),
              ],
            ),
            const SizedBox(height: 12),
            Consumer<BetProvider>(
              builder: (_, p, __) => Text('💰 ₮${p.balance.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [500, 1000, 5000, 10000].map((v) => InkWell(
                onTap: _spinning ? null : () => setState(() => _stake = v.toDouble()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _stake == v.toDouble() ? AppColors.accent : AppColors.bg,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text('${v}₮',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (ctx) => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _spinning ? null : () => _spin(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    disabledBackgroundColor: AppColors.surfaceHov,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(_spinning ? 'ЭРГЭЖ БАЙНА...' : '🎯 ЭРГҮҮЛЭХ',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bt(String key, String label, Color bg) {
    final sel = _bet == key;
    return InkWell(
      onTap: () => setState(() => _bet = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? bg : bg.withOpacity(0.4),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: sel ? Colors.white : Colors.transparent, width: 2),
        ),
        child: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
