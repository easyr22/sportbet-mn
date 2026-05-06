import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../data/bet_provider.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const _ProfileHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _BalanceCard(),
                const SizedBox(height: 12),
                const _QuickActions(),
                const SizedBox(height: 16),
                _MenuSection(
                  title: 'ДАНС',
                  items: [
                    _MenuItem(
                      icon: Icons.add_circle_outline,
                      label: 'Орц нэмэх',
                      color: AppColors.green,
                      onTap: () => _showDepositSheet(context),
                    ),
                    _MenuItem(
                      icon: Icons.remove_circle_outline,
                      label: 'Гарц авах',
                      color: AppColors.orange,
                      onTap: () => _showWithdrawSheet(context),
                    ),
                    _MenuItem(
                      icon: Icons.history,
                      label: 'Гүйлгээний түүх',
                      onTap: () => _showTransactionHistory(context),
                    ),
                    _MenuItem(
                      icon: Icons.receipt_long,
                      label: 'Бетийн түүх',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _MenuSection(
                  title: 'ТОХИРГОО',
                  items: [
                    _MenuItem(icon: Icons.language, label: 'Хэл: Монгол', onTap: () {}),
                    _MenuItem(icon: Icons.attach_money, label: 'Валют: MNT ₮', onTap: () {}),
                    _MenuItem(icon: Icons.notifications_outlined, label: 'Мэдэгдэл', onTap: () {}),
                    _MenuItem(icon: Icons.security, label: 'Нууцлал & Аюулгүй байдал', onTap: () {}),
                  ],
                ),
                const SizedBox(height: 12),
                _MenuSection(
                  title: 'ТУСЛАМЖ',
                  items: [
                    _MenuItem(icon: Icons.support_agent, label: 'Хэрэглэгчийн тусламж', onTap: () {}),
                    _MenuItem(icon: Icons.info_outline, label: 'Бидний тухай', onTap: () {}),
                    _MenuItem(icon: Icons.description_outlined, label: 'Үйлчилгээний нөхцөл', onTap: () {}),
                  ],
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.logout, color: AppColors.red),
                  label: const Text('Гарах', style: TextStyle(color: AppColors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDepositSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _DepositSheet(),
    );
  }

  void _showWithdrawSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _WithdrawSheet(),
    );
  }

  void _showTransactionHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _TransactionHistoryScreen()),
    );
  }
}

// ═══════════════════════════════════════════
// PROFILE HEADER
// ═══════════════════════════════════════════
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16, right: 16, bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gradient1, AppColors.gradient2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('👤', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Тоглогч #84521',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              _GoldBadge(),
            ],
          ),
          const Spacer(),
          Consumer<BetProvider>(
            builder: (_, p, __) => Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                color: p.backendConnected ? AppColors.green : AppColors.textMuted,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _GoldBadge extends StatelessWidget {
  const _GoldBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text('🏆 Алт гишүүн',
          style: TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}

// ═══════════════════════════════════════════
// BALANCE CARD
// ═══════════════════════════════════════════
class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<BetProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.card, AppColors.cardLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Нийт үлдэгдэл',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => provider.refreshBalance(),
                    child: const Icon(Icons.refresh,
                        color: AppColors.textSecondary, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '₮${_fmt(provider.balance)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                      color: provider.backendConnected ? AppColors.green : AppColors.textMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    provider.backendConnected ? 'Серверт холбогдсон' : 'Оффлайн горим',
                    style: TextStyle(
                      color: provider.backendConnected ? AppColors.green : AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(2)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

// ═══════════════════════════════════════════
// QUICK ACTIONS
// ═══════════════════════════════════════════
class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.add_circle,
            label: 'Орц нэмэх',
            color: AppColors.green,
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: AppColors.surface,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              builder: (_) => const _DepositSheet(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.remove_circle,
            label: 'Гарц авах',
            color: AppColors.orange,
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: AppColors.surface,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              builder: (_) => const _WithdrawSheet(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// DEPOSIT SHEET
// ═══════════════════════════════════════════
class _DepositSheet extends StatefulWidget {
  const _DepositSheet();

  @override
  State<_DepositSheet> createState() => _DepositSheetState();
}

class _DepositSheetState extends State<_DepositSheet> {
  final _ctrl = TextEditingController();
  final _amounts = [5000.0, 10000.0, 20000.0, 50000.0, 100000.0, 200000.0];
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _deposit(double amount) async {
    setState(() => _loading = true);
    final provider = context.read<BetProvider>();
    final result = await provider.depositFromBackend(amount);
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result.message),
      backgroundColor: result.success ? AppColors.green : AppColors.red,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.add_circle, color: AppColors.green, size: 22),
              const SizedBox(width: 8),
              const Text('Орц нэмэх',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Consumer<BetProvider>(
            builder: (_, p, __) => Text(
              'Одоогийн үлдэгдэл: ₮${p.balance.toStringAsFixed(0)}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          // Quick amounts
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _amounts.map((a) => GestureDetector(
              onTap: () => _ctrl.text = a.toStringAsFixed(0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.orange.withOpacity(0.4)),
                ),
                child: Text('₮${_fmtK(a)}',
                    style: const TextStyle(
                        color: AppColors.orange, fontWeight: FontWeight.bold)),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),
          // Custom amount
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Дүн оруулах...',
              hintStyle: const TextStyle(color: AppColors.textMuted),
              prefixText: '₮ ',
              prefixStyle: const TextStyle(color: AppColors.green, fontSize: 16),
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.green),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading
                  ? null
                  : () {
                      final amount = double.tryParse(_ctrl.text.replaceAll(',', ''));
                      if (amount == null || amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Зөв дүн оруулна уу'),
                              backgroundColor: AppColors.red),
                        );
                        return;
                      }
                      _deposit(amount);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Орц нэмэх',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtK(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

// ═══════════════════════════════════════════
// WITHDRAW SHEET
// ═══════════════════════════════════════════
class _WithdrawSheet extends StatefulWidget {
  const _WithdrawSheet();

  @override
  State<_WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends State<_WithdrawSheet> {
  final _ctrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _withdraw(double amount) async {
    setState(() => _loading = true);
    final provider = context.read<BetProvider>();
    final result = await provider.withdrawFromBackend(amount);
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result.message),
      backgroundColor: result.success ? AppColors.green : AppColors.red,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Consumer<BetProvider>(
      builder: (context, provider, _) {
        final amounts = [
          provider.balance * 0.25,
          provider.balance * 0.5,
          provider.balance * 0.75,
          provider.balance,
        ].where((a) => a >= 1000).toList();

        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.remove_circle, color: AppColors.orange, size: 22),
                  const SizedBox(width: 8),
                  const Text('Гарц авах',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Боломжит: ₮${provider.balance.toStringAsFixed(0)}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              // Percent buttons
              if (amounts.isNotEmpty)
                Row(
                  children: ['25%', '50%', '75%', 'MAX'].asMap().entries.map((entry) {
                    final pct = ['25%', '50%', '75%', 'MAX'][entry.key];
                    final amt = amounts[entry.key];
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: entry.key == 0 ? 0 : 4,
                            right: entry.key == 3 ? 0 : 4),
                        child: GestureDetector(
                          onTap: () => _ctrl.text = amt.toStringAsFixed(0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.orange.withOpacity(0.4)),
                            ),
                            child: Center(
                              child: Text(pct,
                                  style: const TextStyle(
                                      color: AppColors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: _ctrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Дүн оруулах...',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  prefixText: '₮ ',
                  prefixStyle: const TextStyle(color: AppColors.orange, fontSize: 16),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.orange),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Хамгийн багадаа ₮1,000 гаргах боломжтой',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () {
                          final amount = double.tryParse(
                              _ctrl.text.replaceAll(',', ''));
                          if (amount == null || amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Зөв дүн оруулна уу'),
                                  backgroundColor: AppColors.red),
                            );
                            return;
                          }
                          _withdraw(amount);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Гарц авах',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════
// TRANSACTION HISTORY SCREEN
// ═══════════════════════════════════════════
class _TransactionHistoryScreen extends StatefulWidget {
  const _TransactionHistoryScreen();

  @override
  State<_TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<_TransactionHistoryScreen> {
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
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Гүйлгээний түүх',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            onPressed: () { setState(() => _loading = true); _load(); },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
          : _txs.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('📋', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 12),
                      Text('Гүйлгээний түүх байхгүй',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 14)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _txs.length,
                  itemBuilder: (_, i) => _TxTile(tx: _txs[i]),
                ),
    );
  }
}

class _TxTile extends StatelessWidget {
  final Map<String, dynamic> tx;
  const _TxTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isDeposit = tx['type'] == 'deposit';
    final amount = (tx['amount'] as num).toDouble();
    final balance = (tx['balance'] as num).toDouble();
    final ts = DateTime.tryParse(tx['timestamp'] as String? ?? '') ?? DateTime.now();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: (isDeposit ? AppColors.green : AppColors.orange).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                isDeposit ? Icons.add_circle_outline : Icons.remove_circle_outline,
                color: isDeposit ? AppColors.green : AppColors.orange,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDeposit ? 'Орц нэмсэн' : 'Гарц авсан',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${ts.year}-${_pad(ts.month)}-${_pad(ts.day)} ${_pad(ts.hour)}:${_pad(ts.minute)}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isDeposit ? '+' : '-'}₮${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  color: isDeposit ? AppColors.green : AppColors.orange,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₮${balance.toStringAsFixed(0)}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}

// ═══════════════════════════════════════════
// MENU SECTION
// ═══════════════════════════════════════════
class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final isLast = entry.key == items.length - 1;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon,
                        color: item.color ?? AppColors.textSecondary, size: 20),
                    title: Text(item.label,
                        style: const TextStyle(color: Colors.white, fontSize: 14)),
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.textMuted, size: 18),
                    onTap: item.onTap,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    visualDensity: VisualDensity.compact,
                  ),
                  if (!isLast)
                    const Divider(
                        color: AppColors.divider, height: 1, indent: 52),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
  });
}
