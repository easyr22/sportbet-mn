import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../data/bet_provider.dart';
import '../services/api_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BetProvider>(
      builder: (_, prov, __) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Миний данс',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _BalanceCard(prov: prov),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _ActionBtn(
                  icon: Icons.add_circle_outline, label: 'Орц нэмэх',
                  color: AppColors.green,
                  onTap: () => _showDeposit(context, prov),
                )),
                const SizedBox(width: 12),
                Expanded(child: _ActionBtn(
                  icon: Icons.remove_circle_outline, label: 'Гаргах',
                  color: AppColors.orange,
                  onTap: () => _showWithdraw(context, prov),
                )),
              ]),
              const SizedBox(height: 24),
              const Text('Гүйлгээний түүх',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              _TransactionList(),
            ]),
          ),
        ),
      ),
    );
  }

  void _showDeposit(BuildContext context, BetProvider prov) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _DepositSheet(prov: prov),
    );
  }

  void _showWithdraw(BuildContext context, BetProvider prov) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _WithdrawSheet(prov: prov),
    );
  }
}

// ── Balance card ──────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  final BetProvider prov;
  const _BalanceCard({required this.prov});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF1a2a4a), Color(0xFF0f1a2e)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.circle, size: 8,
              color: prov.backendConnected ? AppColors.green : AppColors.textMuted),
          const SizedBox(width: 6),
          Text(prov.backendConnected ? 'Сервертэй холбогдсон' : 'Офлайн',
              style: TextStyle(
                  color: prov.backendConnected ? AppColors.green : AppColors.textMuted,
                  fontSize: 11)),
          const Spacer(),
          GestureDetector(
            onTap: prov.refreshBalance,
            child: const Icon(Icons.refresh, size: 16, color: AppColors.textMuted),
          ),
        ]),
        const SizedBox(height: 12),
        const Text('Нийт үлдэгдэл',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          '₮${_fmt(prov.balance)}',
          style: const TextStyle(
              color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ]),
    );
  }

  String _fmt(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ── Action buttons ────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

// ── Transaction list ──────────────────────────────────────────────────────────

class _TransactionList extends StatefulWidget {
  @override
  State<_TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<_TransactionList> {
  List<Map<String, dynamic>> _txs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final txs = await ApiService.fetchTransactions();
    if (mounted) setState(() { _txs = txs; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.orange));
    if (_txs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
        child: const Center(
          child: Text('Гүйлгээ байхгүй байна',
              style: TextStyle(color: AppColors.textMuted)),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider)),
      child: Column(
        children: _txs.take(20).map((tx) => _TxRow(tx: tx)).toList(),
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  final Map<String, dynamic> tx;
  const _TxRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isDeposit = tx['type'] == 'deposit';
    final amt = (tx['amount'] as num).toDouble();
    final col = isDeposit ? AppColors.green : AppColors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5))),
      child: Row(children: [
        Icon(isDeposit ? Icons.arrow_downward : Icons.arrow_upward, size: 16, color: col),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tx['note'] as String? ?? (isDeposit ? 'Орц' : 'Гаргалт'),
                style: const TextStyle(color: Colors.white, fontSize: 12)),
            Text(_formatDate(tx['timestamp'] as String? ?? ''),
                style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
          ]),
        ),
        Text(
          '${isDeposit ? '+' : '-'}₮${amt.toStringAsFixed(0)}',
          style: TextStyle(color: col, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ]),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.year}-${_p(dt.month)}-${_p(dt.day)}  ${_p(dt.hour)}:${_p(dt.minute)}';
    } catch (_) { return iso; }
  }
  String _p(int n) => n.toString().padLeft(2, '0');
}

// ── Deposit sheet ─────────────────────────────────────────────────────────────

class _DepositSheet extends StatefulWidget {
  final BetProvider prov;
  const _DepositSheet({required this.prov});
  @override
  State<_DepositSheet> createState() => _DepositSheetState();
}

class _DepositSheetState extends State<_DepositSheet> {
  final _ctrl = TextEditingController();
  String? _msg;
  bool _ok = false, _busy = false;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Орц нэмэх', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8,
            children: [10000, 20000, 50000, 100000].map((a) => _QuickChip(
              label: '₮${a ~/ 1000}K',
              onTap: () => _ctrl.text = '$a',
            )).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl, keyboardType: TextInputType.number, autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: _dec('Дүн оруулах...'),
          ),
          const SizedBox(height: 12),
          if (_msg != null) _Banner(msg: _msg!, ok: _ok),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _busy ? null : _submit,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: _busy
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Нэмэх', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _submit() async {
    final amt = double.tryParse(_ctrl.text.trim());
    if (amt == null || amt <= 0) {
      setState(() { _msg = 'Зөв дүн оруулна уу'; _ok = false; });
      return;
    }
    setState(() => _busy = true);
    final r = await widget.prov.depositFromBackend(amt);
    setState(() { _busy = false; _msg = r.message; _ok = r.success; });
    if (r.success) { _ctrl.clear(); Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context)); }
  }

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint, hintStyle: const TextStyle(color: AppColors.textMuted),
    filled: true, fillColor: AppColors.cardLight,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.green)),
  );
}

// ── Withdraw sheet ────────────────────────────────────────────────────────────

class _WithdrawSheet extends StatefulWidget {
  final BetProvider prov;
  const _WithdrawSheet({required this.prov});
  @override
  State<_WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends State<_WithdrawSheet> {
  final _ctrl = TextEditingController();
  String? _msg;
  bool _ok = false, _busy = false;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final bal = widget.prov.balance;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Гаргах', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Үлдэгдэл: ₮${bal.toStringAsFixed(0)}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8,
            children: [0.25, 0.5, 0.75, 1.0].map((pct) => _QuickChip(
              label: pct == 1.0 ? 'БҮГД' : '${(pct * 100).toInt()}%',
              onTap: () => _ctrl.text = (bal * pct).toStringAsFixed(0),
            )).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl, keyboardType: TextInputType.number, autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: _dec('Дүн оруулах...'),
          ),
          const SizedBox(height: 12),
          if (_msg != null) _Banner(msg: _msg!, ok: _ok),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _busy ? null : _submit,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: _busy
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Гаргах', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _submit() async {
    final amt = double.tryParse(_ctrl.text.trim());
    if (amt == null || amt <= 0) {
      setState(() { _msg = 'Зөв дүн оруулна уу'; _ok = false; }); return;
    }
    setState(() => _busy = true);
    final r = await widget.prov.withdrawFromBackend(amt);
    setState(() { _busy = false; _msg = r.message; _ok = r.success; });
    if (r.success) { _ctrl.clear(); Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context)); }
  }

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint, hintStyle: const TextStyle(color: AppColors.textMuted),
    filled: true, fillColor: AppColors.cardLight,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.orange)),
  );
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
            color: AppColors.cardLight,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.divider)),
        child: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final String msg;
  final bool ok;
  const _Banner({required this.msg, required this.ok});

  @override
  Widget build(BuildContext context) {
    final col = ok ? AppColors.green : AppColors.liveRed;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: col.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: col.withOpacity(0.4))),
      child: Row(children: [
        Icon(ok ? Icons.check_circle_outline : Icons.error_outline, size: 14, color: col),
        const SizedBox(width: 8),
        Expanded(child: Text(msg, style: TextStyle(color: col, fontSize: 12))),
      ]),
    );
  }
}
