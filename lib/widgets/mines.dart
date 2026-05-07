import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../data/bet_provider.dart';

class MinesDialog extends StatefulWidget {
  final String gameName;
  const MinesDialog({super.key, required this.gameName});
  @override
  State<MinesDialog> createState() => _MinesDialogState();
}

class _MinesDialogState extends State<MinesDialog> {
  static const _gridSize = 5; // 5x5
  final _rng = Random();
  Set<int> _mines = {};
  Set<int> _revealed = {};
  bool _playing = false;
  bool _busted = false;
  double _stake = 1000;
  int _mineCount = 5;
  String? _msg;
  Color _msgColor = AppColors.accent;

  double get _mult {
    final safe = _gridSize * _gridSize - _mineCount;
    final found = _revealed.length;
    if (found == 0) return 1.0;
    // Multiplier formula: product of (safe-i)/(safe-i-found+i) approximation
    double m = 1.0;
    for (int i = 0; i < found; i++) {
      m *= (safe - i) / (safe - i - 1).clamp(1, safe);
    }
    return double.parse(m.toStringAsFixed(2));
  }

  void _start(BuildContext ctx) {
    final prov = ctx.read<BetProvider>();
    if (_stake > prov.balance) {
      setState(() { _msg = 'Үлдэгдэл хүрэлцэхгүй'; _msgColor = AppColors.liveRed; });
      return;
    }
    prov.deposit(-_stake);
    final all = List.generate(_gridSize * _gridSize, (i) => i)..shuffle(_rng);
    setState(() {
      _mines = all.take(_mineCount).toSet();
      _revealed = {};
      _playing = true; _busted = false; _msg = null;
    });
  }

  void _reveal(int i, BuildContext ctx) {
    if (!_playing || _busted) return;
    if (_revealed.contains(i)) return;
    setState(() {
      _revealed.add(i);
      if (_mines.contains(i)) {
        _busted = true; _playing = false;
        _msg = '💣 Мина! Бооцоо алдсан';
        _msgColor = AppColors.liveRed;
      }
    });
  }

  void _cashOut(BuildContext ctx) {
    if (!_playing || _revealed.isEmpty) return;
    final win = _stake * _mult;
    ctx.read<BetProvider>().deposit(win);
    setState(() {
      _playing = false;
      _msg = '💎 Гарсан ${_mult.toStringAsFixed(2)}× — +${win.toStringAsFixed(0)}₮';
      _msgColor = AppColors.accent;
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
              const Text('💣', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(child: Text(widget.gameName,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800))),
              IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
            ]),
            const SizedBox(height: 8),
            // Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat('Мина', '$_mineCount', AppColors.liveRed),
                _Stat('Олсон', '${_revealed.where((i) => !_mines.contains(i)).length}', AppColors.accent),
                _Stat('×', _mult.toStringAsFixed(2), AppColors.orange),
              ],
            ),
            const SizedBox(height: 14),
            // Grid
            Builder(
              builder: (ctx) => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _gridSize,
                  crossAxisSpacing: 6, mainAxisSpacing: 6,
                ),
                itemCount: _gridSize * _gridSize,
                itemBuilder: (_, i) {
                  final revealed = _revealed.contains(i);
                  final isMine = _mines.contains(i);
                  Color bg = AppColors.bg;
                  String? content;
                  if (revealed) {
                    bg = isMine ? AppColors.liveRed : AppColors.accent;
                    content = isMine ? '💣' : '💎';
                  } else if (_busted && isMine) {
                    bg = AppColors.liveRed.withOpacity(0.4);
                    content = '💣';
                  }
                  return InkWell(
                    onTap: _playing && !revealed ? () => _reveal(i, ctx) : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.border),
                      ),
                      alignment: Alignment.center,
                      child: Text(content ?? '', style: const TextStyle(fontSize: 24)),
                    ),
                  );
                },
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
            const SizedBox(height: 8),
            Consumer<BetProvider>(
              builder: (_, p, __) => Text('💰 ₮${p.balance.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [500, 1000, 5000, 10000].map((v) => InkWell(
                onTap: _playing ? null : () => setState(() => _stake = v.toDouble()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _stake == v.toDouble() ? AppColors.accent : AppColors.bg,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text('$v₮',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 10),
            Builder(
              builder: (ctx) => Row(children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _playing ? null : () => _start(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      disabledBackgroundColor: AppColors.surfaceHov,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('💎 START', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_playing && _revealed.isNotEmpty) ? () => _cashOut(ctx) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      disabledBackgroundColor: AppColors.surfaceHov,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(_playing ? 'CASH OUT ${(_stake * _mult).toStringAsFixed(0)}₮' : 'CASH OUT',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Stat(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
    ]);
  }
}
