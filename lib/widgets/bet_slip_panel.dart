import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../data/bet_provider.dart';
import '../models/bet_item.dart';

class BetSlipPanel extends StatefulWidget {
  const BetSlipPanel({super.key});

  @override
  State<BetSlipPanel> createState() => _BetSlipPanelState();
}

class _BetSlipPanelState extends State<BetSlipPanel> {
  final _ctrl = TextEditingController(text: '1000');
  String? _msg;
  bool _ok = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: AppColors.sidebar,
      child: Consumer<BetProvider>(
        builder: (_, prov, __) => Column(
          children: [
            _Header(count: prov.betCount, onClear: prov.clearSlip),
            Expanded(
              child: prov.betCount == 0
                  ? const _EmptyState()
                  : ListView(
                      padding: const EdgeInsets.all(10),
                      children: [
                        _ModeRow(prov: prov),
                        const SizedBox(height: 8),
                        ...prov.betSlip.map((b) => _BetCard(bet: b, prov: prov)),
                        const SizedBox(height: 10),
                        _SummaryBox(prov: prov),
                        const SizedBox(height: 10),
                        _StakeBox(ctrl: _ctrl, prov: prov),
                        const SizedBox(height: 10),
                        _PlaceBtn(
                          prov: prov,
                          ctrl: _ctrl,
                          onDone: (msg, ok) => setState(() {
                            _msg = msg;
                            _ok = ok;
                          }),
                        ),
                        if (_msg != null) ...[
                          const SizedBox(height: 8),
                          _ResultBanner(msg: _msg!, ok: _ok),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final int count;
  final VoidCallback onClear;
  const _Header({required this.count, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long, size: 15, color: AppColors.orange),
          const SizedBox(width: 8),
          const Text('Бетийн цаас',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          const Spacer(),
          if (count > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                  color: AppColors.orange, borderRadius: BorderRadius.circular(10)),
              child: Text('$count',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClear,
              child: const Icon(Icons.delete_outline, size: 15, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 40, color: AppColors.textMuted),
          SizedBox(height: 10),
          Text('Бет сонгоогүй байна',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          SizedBox(height: 4),
          Text('Коэффициент дарж нэмнэ үү',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

// ── Mode toggle ───────────────────────────────────────────────────────────────

class _ModeRow extends StatelessWidget {
  final BetProvider prov;
  const _ModeRow({required this.prov});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          _Mode('Аккумулятор', BetSlipMode.accumulator, prov),
          _Mode('Тус бүр', BetSlipMode.single, prov),
        ],
      ),
    );
  }
}

class _Mode extends StatelessWidget {
  final String label;
  final BetSlipMode mode;
  final BetProvider prov;
  const _Mode(this.label, this.mode, this.prov);

  @override
  Widget build(BuildContext context) {
    final active = prov.mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => prov.setMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: active ? AppColors.orange : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: active ? Colors.white : AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

// ── Bet card ──────────────────────────────────────────────────────────────────

class _BetCard extends StatelessWidget {
  final BetItem bet;
  final BetProvider prov;
  const _BetCard({required this.bet, required this.prov});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text('${bet.homeTeam} — ${bet.awayTeam}',
                style: const TextStyle(
                    color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
          ),
          GestureDetector(
            onTap: () => prov.removeFromSlip(bet.id, bet.eventId),
            child: const Icon(Icons.close, size: 13, color: AppColors.textMuted),
          ),
        ]),
        const SizedBox(height: 3),
        Text('${bet.marketName}: ${bet.optionLabel}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
        const SizedBox(height: 5),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(bet.league,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 9)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.orange.withOpacity(0.4)),
            ),
            child: Text(bet.odds.toStringAsFixed(2),
                style: const TextStyle(
                    color: AppColors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ]),
      ]),
    );
  }
}

// ── Summary box ───────────────────────────────────────────────────────────────

class _SummaryBox extends StatelessWidget {
  final BetProvider prov;
  const _SummaryBox({required this.prov});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(children: [
        _Row('Нийт коэффициент', prov.totalOdds.toStringAsFixed(2)),
        const SizedBox(height: 4),
        _Row(
          'Боломжит ашиг',
          '₮${(prov.stake * prov.totalOdds).toStringAsFixed(0)}',
          highlight: true,
        ),
      ]),
    );
  }

  Widget _Row(String label, String value, {bool highlight = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      Text(value,
          style: TextStyle(
              color: highlight ? AppColors.green : Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold)),
    ]);
  }
}

// ── Stake input ───────────────────────────────────────────────────────────────

class _StakeBox extends StatelessWidget {
  final TextEditingController ctrl;
  final BetProvider prov;
  const _StakeBox({required this.ctrl, required this.prov});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Бетийн дүн (₮)',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      const SizedBox(height: 5),
      TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: AppColors.orange)),
        ),
        onChanged: (v) {
          final d = double.tryParse(v);
          if (d != null) prov.setStake(d);
        },
      ),
      const SizedBox(height: 6),
      Row(
        children: [1000, 5000, 10000, 50000].map((amt) {
          return Expanded(
            child: GestureDetector(
              onTap: () {
                ctrl.text = '$amt';
                prov.setStake(amt.toDouble());
              },
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Center(
                  child: Text(
                    amt >= 1000 ? '${amt ~/ 1000}K' : '$amt',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ]);
  }
}

// ── Place bet button ──────────────────────────────────────────────────────────

class _PlaceBtn extends StatelessWidget {
  final BetProvider prov;
  final TextEditingController ctrl;
  final void Function(String, bool) onDone;
  const _PlaceBtn({required this.prov, required this.ctrl, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final canBet = prov.betCount > 0 && prov.stake > 0 && prov.stake <= prov.balance;
    final label = prov.stake > prov.balance
        ? 'Үлдэгдэл хүрэлцэхгүй'
        : prov.betCount == 0
            ? 'Бет сонгоно уу'
            : 'Бет тавих  ₮${prov.stake.toStringAsFixed(0)}';

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canBet
            ? () {
                final ok = prov.placeBet();
                ctrl.text = '1000';
                onDone(
                  ok ? 'Амжилттай бет тавигдлаа! 🎉' : 'Алдаа гарлаа',
                  ok,
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          disabledBackgroundColor: AppColors.textMuted,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          elevation: 0,
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ── Result banner ─────────────────────────────────────────────────────────────

class _ResultBanner extends StatelessWidget {
  final String msg;
  final bool ok;
  const _ResultBanner({required this.msg, required this.ok});

  @override
  Widget build(BuildContext context) {
    final col = ok ? AppColors.green : AppColors.liveRed;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: col.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: col.withOpacity(0.4)),
      ),
      child: Row(children: [
        Icon(ok ? Icons.check_circle_outline : Icons.error_outline, size: 15, color: col),
        const SizedBox(width: 8),
        Expanded(child: Text(msg, style: TextStyle(color: col, fontSize: 12))),
      ]),
    );
  }
}
