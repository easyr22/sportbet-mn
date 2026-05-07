import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../data/bet_provider.dart';
import '../services/auth_service.dart';
import 'auth_dialog.dart';

class TopBar extends StatelessWidget {
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const TopBar({super.key, required this.currentPage, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 700;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top utility bar — hidden on mobile to save space
        if (!isMobile) Container(
          height: 32,
          color: AppColors.headerTop,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _MiniLink(Icons.phone_iphone, 'MOBILE'),
              _MiniLink(Icons.notifications_none, 'МЭДЭГДЭЛ'),
              _MiniLink(Icons.bar_chart, 'СТАТИСТИК'),
              const Spacer(),
              const Text('30 days bonus',
                  style: TextStyle(color: AppColors.orange, fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(width: 16),
              _LangChip('🇲🇳 MN'),
              const SizedBox(width: 8),
              if (AuthService.isLoggedIn) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person, size: 12, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(AuthService.username ?? '', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Builder(
                  builder: (ctx) => _AuthBtn('Гарах', AppColors.surfaceHov, Colors.white, onTap: () async {
                    await AuthService.logout();
                    if (ctx.mounted) await ctx.read<BetProvider>().refreshBalance();
                  }),
                ),
              ] else ...[
                Builder(
                  builder: (ctx) => _AuthBtn('Нэвтрэх', AppColors.surfaceHov, Colors.white, onTap: () {
                    showDialog(context: ctx, builder: (_) => const AuthDialog(startOnRegister: false));
                  }),
                ),
                const SizedBox(width: 6),
                Builder(
                  builder: (ctx) => _AuthBtn('Бүртгүүлэх', AppColors.accent, Colors.white, onTap: () {
                    showDialog(context: ctx, builder: (_) => const AuthDialog(startOnRegister: true));
                  }),
                ),
              ],
            ],
          ),
        ),
        // Main nav bar with logo and tabs
        Container(
          height: 52,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.blueDark, AppColors.blue],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _Logo(),
              const SizedBox(width: 18),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _NavTab('СПОРТ',       0,  currentPage, onPageChanged),
                      _NavTab('ЛАЙВ',        1,  currentPage, onPageChanged),
                      _NavTab('ЭСПОРТ',      3,  currentPage, onPageChanged),
                      _NavTab('КАЗИНО',      4,  currentPage, onPageChanged),
                      _NavTab('LIVE CASINO', 5,  currentPage, onPageChanged),
                      _NavTab('ПРОМО',       6,  currentPage, onPageChanged),
                      _NavTab('TV ТОГЛООМ',  7,  currentPage, onPageChanged),
                      _NavTab('БИНГО',       8,  currentPage, onPageChanged),
                      _NavTab('TOTO',        9,  currentPage, onPageChanged),
                      _NavTab('ҮР ДҮН',      10, currentPage, onPageChanged),
                      _NavTab('ПРОФАЙЛ',     2,  currentPage, onPageChanged),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Consumer<BetProvider>(
                builder: (_, p, __) => _BalanceChip(balance: p.balance, connected: p.backendConnected),
              ),
              const SizedBox(width: 6),
              if (isMobile && !AuthService.isLoggedIn)
                Builder(
                  builder: (ctx) => InkWell(
                    onTap: () => showDialog(context: ctx, builder: (_) => const AuthDialog(startOnRegister: true)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(3)),
                      child: const Text('Орох', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
              if (isMobile && AuthService.isLoggedIn)
                Builder(
                  builder: (ctx) => InkWell(
                    onTap: () async {
                      await AuthService.logout();
                      if (ctx.mounted) await ctx.read<BetProvider>().refreshBalance();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: AppColors.surfaceHov, borderRadius: BorderRadius.circular(3)),
                      child: const Icon(Icons.logout, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              Consumer<BetProvider>(
                builder: (_, p, __) => p.betCount > 0
                    ? _SlipBadge(count: p.betCount)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniLink extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MiniLink(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  const _LangChip(this.label);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceHov,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
    );
  }
}

class _AuthBtn extends StatelessWidget {
  final String label;
  final Color bg, fg;
  final VoidCallback? onTap;
  const _AuthBtn(this.label, this.bg, this.fg, {this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(3)),
        child: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
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
        const Text(
          'Sport',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: const Text(
            'Bet',
            style: TextStyle(color: Color(0xFFFFCC00), fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(3),
          ),
          child: const Text('MN', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.12) : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: 0.3,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: connected ? AppColors.accentLight : AppColors.textMuted),
          const SizedBox(width: 6),
          Text(
            '₮${_fmt(balance)}',
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(3)),
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
