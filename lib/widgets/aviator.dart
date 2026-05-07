import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../data/bet_provider.dart';

class AviatorDialog extends StatefulWidget {
  final String gameName;
  const AviatorDialog({super.key, required this.gameName});
  @override
  State<AviatorDialog> createState() => _AviatorDialogState();
}

class _AviatorDialogState extends State<AviatorDialog> {
  final _rng = Random();
  Timer? _timer;
  double _mult = 1.00;
  double _crashAt = 1.00;
  bool _flying = false;
  bool _bet = false;
  bool _cashedOut = false;
  double _stake = 1000;
  String? _msg;
  Color _msgColor = AppColors.accent;
  final List<double> _history = [2.34, 1.45, 8.12, 1.02, 3.67, 1.88, 5.21];

  void _placeAndStart(BuildContext ctx) {
    if (_flying) return;
    final prov = ctx.read<BetProvider>();
    if (_stake > prov.balance) {
      setState(() { _msg = 'Үлдэгдэл хүрэлцэхгүй'; _msgColor = AppColors.liveRed; });
      return;
    }
    prov.deposit(-_stake);
    // Pick crash point: weighted - mostly low (1.0-3.0), occasional big
    final r = _rng.nextDouble();
    if (r < 0.30) _crashAt = 1.0 + _rng.nextDouble() * 0.5;       // 1.0-1.5
    else if (r < 0.65) _crashAt = 1.5 + _rng.nextDouble() * 1.5;  // 1.5-3.0
    else if (r < 0.90) _crashAt = 3.0 + _rng.nextDouble() * 4.0;  // 3.0-7.0
    else _crashAt = 7.0 + _rng.nextDouble() * 18.0;               // 7.0-25.0

    setState(() {
      _flying = true; _bet = true; _cashedOut = false;
      _mult = 1.00; _msg = null;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() { _mult += 0.04 + _mult * 0.012; });
      if (_mult >= _crashAt) {
        _timer?.cancel();
        setState(() {
          _flying = false;
          if (!_cashedOut) {
            _msg = '💥 Шатлаа ${_crashAt.toStringAsFixed(2)}× — алдсан';
            _msgColor = AppColors.liveRed;
            _bet = false;
          }
          _history.insert(0, _crashAt);
          if (_history.length > 10) _history.removeLast();
        });
      }
    });
  }

  void _cashOut(BuildContext ctx) {
    if (!_flying || _cashedOut) return;
    final win = _stake * _mult;
    ctx.read<BetProvider>().deposit(win);
    setState(() {
      _cashedOut = true; _bet = false;
      _msg = '✈️ ${_mult.toStringAsFixed(2)}× гарлаа! +${win.toStringAsFixed(0)}₮';
      _msgColor = AppColors.accent;
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  Color _multColor() {
    if (_mult < 2) return Colors.white;
    if (_mult < 5) return AppColors.accentLight;
    if (_mult < 10) return AppColors.orange;
    return const Color(0xFFFFD700);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A1A), Color(0xFF6A1B9A), Color(0xFFE53935)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              const Text('✈️', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(child: Text(widget.gameName,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800))),
              IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
            ]),
            // History pills
            SizedBox(
              height: 22,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _history.map((h) => Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: h < 2 ? AppColors.liveRed : (h < 5 ? AppColors.orange : AppColors.accent),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text('${h.toStringAsFixed(2)}×',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                )).toList(),
              ),
            ),
            const SizedBox(height: 12),
            // Multiplier display
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  if (_flying)
                    Positioned.fill(
                      child: CustomPaint(painter: _CurvePainter(_mult)),
                    ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('✈️',
                            style: TextStyle(fontSize: _flying ? 32 + _mult * 2 : 36)),
                        const SizedBox(height: 8),
                        Text('${_mult.toStringAsFixed(2)}×',
                            style: TextStyle(
                                color: _flying ? _multColor() : (_mult > _crashAt ? AppColors.liveRed : Colors.white),
                                fontSize: 48, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_msg != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _msgColor.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: _msgColor),
                ),
                child: Text(_msg!,
                    style: TextStyle(color: _msgColor, fontSize: 13, fontWeight: FontWeight.w800)),
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
                onTap: _flying ? null : () => setState(() => _stake = v.toDouble()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: _stake == v.toDouble() ? Colors.white : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('$v₮',
                      style: TextStyle(
                          color: _stake == v.toDouble() ? Colors.black : Colors.white,
                          fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (ctx) => Row(children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _flying ? null : () => _placeAndStart(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      disabledBackgroundColor: AppColors.surfaceHov,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('🚀 START', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_flying && !_cashedOut && _bet) ? () => _cashOut(ctx) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      disabledBackgroundColor: AppColors.surfaceHov,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(_flying ? 'CASH OUT ${(_stake * _mult).toStringAsFixed(0)}₮' : 'CASH OUT',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
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

class _CurvePainter extends CustomPainter {
  final double mult;
  _CurvePainter(this.mult);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.orange
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(0, size.height);
    final progress = (mult - 1.0).clamp(0.0, 5.0) / 5.0;
    path.quadraticBezierTo(
      size.width * 0.5, size.height,
      size.width * progress, size.height * (1 - progress * 0.85),
    );
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(_) => true;
}
