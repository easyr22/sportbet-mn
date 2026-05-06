import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../data/bet_provider.dart';

class TopBar extends StatelessWidget {
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const TopBar({super.key, required this.currentPage, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: AppColors.header,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _Logo(),
          const SizedBox(width: 28),
          Row(
            children: [
              _NavTab('⚽ Спорт',   0, currentPage, onPageChanged),
              _NavTab('🔴 Лайв',    1, currentPage, onPageChanged),
              _NavTab('👤 Профайл', 2, currentPage, onPageChanged),
            ],
          ),
          const Spacer(),
          Consumer<BetProvider>(
            builder: (_, p, __) => _BalanceChip(balance: p.balance, connected: p.backendConnected),
          ),
          const SizedBox(width: 10),
          Consumer<BetProvider>(
            builder: (_, p, __) => p.betCount > 0
                ? _SlipBadge(count: p.betCount)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.orange, AppColors.liveRed]),
            borderRadius: BorderRadius.circular(7),
          ),
          child: const Icon(Icons.sports_soccer, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        const Text('Sport', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
        const Text('Bet', style: TextStyle(color: AppColors.orange, fontSize: 17, fontWeight: FontWeight.bold)),
        const Text(' MN', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ],
    );
  }
}

class _NavTab extends StatelessWidget {
  final String label;
  final int idx, cur;
  final ValueChanged<int> onTap;

  const _NavTab(this.label, this.idx, this.cur, this.onTap);

  @override
  Widget build(BuildContext context) {
    final active = idx == cur;
    return InkWell(
      onTap: () => onTap(idx),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        margin: const EdgeInsets.only(right: 2),
        decoration: BoxDecoration(
          color: active ? AppColors.orange.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: active
              ? const Border(bottom: BorderSide(color: AppColors.orange, width: 2))
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppColors.orange : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _BalanceChip extends StatelessWidget {
  final double balance;
  final bool connected;

  const _BalanceChip({required this.balance, required this.connected});

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: connected ? AppColors.green : AppColors.textMuted),
          const SizedBox(width: 6),
          Text(
            '₮${_fmt(balance)}',
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SlipBadge extends StatelessWidget {
  final int count;
  const _SlipBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: AppColors.orange, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long, size: 13, color: Colors.white),
          const SizedBox(width: 4),
          Text('$count', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
