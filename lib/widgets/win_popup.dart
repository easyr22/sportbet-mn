import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class WinPopupOverlay extends StatefulWidget {
  final Widget child;
  const WinPopupOverlay({super.key, required this.child});
  @override
  State<WinPopupOverlay> createState() => _WinPopupOverlayState();
}

class _WinPopupOverlayState extends State<WinPopupOverlay> with TickerProviderStateMixin {
  Timer? _timer;
  final _rng = Random();
  bool _show = false;
  late AnimationController _anim;
  String _name = '', _amount = '', _match = '';

  static const _names = ['Bat***ar','Tem***en','Sar***il','Och***bat','Bil***uun','Mun***zay','Anu***aa','easyR22'];
  static const _matches = ['Real Madrid - Barcelona','NaVi - FaZe Clan','T1 - Gen.G','Sweet Bonanza','Aviator','Lightning Roulette'];
  static const _amounts = ['+45,000₮','+87,200₮','+125,400₮','+250,000₮','+520,000₮'];

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _scheduleNext();
  }

  void _scheduleNext() {
    _timer = Timer(Duration(seconds: 18 + _rng.nextInt(20)), () {
      if (!mounted) return;
      setState(() {
        _name = _names[_rng.nextInt(_names.length)];
        _amount = _amounts[_rng.nextInt(_amounts.length)];
        _match = _matches[_rng.nextInt(_matches.length)];
        _show = true;
      });
      _anim.forward(from: 0);
      Timer(const Duration(seconds: 5), () {
        if (!mounted) return;
        _anim.reverse().then((_) {
          if (mounted) setState(() => _show = false);
        });
        _scheduleNext();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_show)
          Positioned(
            left: 16, bottom: 16,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.5, 0), end: Offset.zero,
              ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutBack)),
              child: FadeTransition(
                opacity: _anim,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF22B14C), Color(0xFF15497F)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.5),
                          blurRadius: 20, spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFFFD700), width: 2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFFD700), width: 2),
                          ),
                          alignment: Alignment.center,
                          child: const Text('🎉', style: TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Text(_name,
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                                  const SizedBox(width: 4),
                                  const Text('ялагдлаа',
                                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(_match,
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white70, fontSize: 10)),
                              const SizedBox(height: 2),
                              Text(_amount,
                                  style: const TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
