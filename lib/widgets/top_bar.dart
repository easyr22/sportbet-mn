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
              Builder(builder: (ctx) => _MiniLink(Icons.phone_iphone, 'MOBILE',
                  onTap: () => showDialog(context: ctx, builder: (_) => const _MobileDialog()))),
              Builder(builder: (ctx) => _MiniLink(Icons.notifications_none, 'МЭДЭГДЭЛ',
                  onTap: () => showDialog(context: ctx, builder: (_) => const _NotificationsDialog()))),
              Builder(builder: (ctx) => _MiniLink(Icons.bar_chart, 'СТАТИСТИК',
                  onTap: () => showDialog(context: ctx, builder: (_) => const _StatsDialog()))),
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
                      _NavTab('🤖 AI',       11, currentPage, onPageChanged),
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
  final VoidCallback? onTap;
  const _MiniLink(this.icon, this.label, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Row(
          children: [
            Icon(icon, size: 13, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _MobileDialog extends StatelessWidget {
  const _MobileDialog();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              const Icon(Icons.phone_iphone, color: AppColors.accent, size: 22),
              const SizedBox(width: 8),
              const Text('МОБАЙЛ АППЛИКЕЙШН',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                  onPressed: () => Navigator.pop(context)),
            ]),
            const SizedBox(height: 8),
            const Text('Утсан дээрээ аппликейшн шиг суулгах боломжтой',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 18),
            _PlatformBlock(
              icon: '🍎', title: 'iOS / iPhone',
              steps: ['1. Safari браузерт нээх',
                      '2. Доорх ⤴ Share товч',
                      '3. "Add to Home Screen"',
                      '4. "Add" дарах'],
            ),
            const SizedBox(height: 14),
            _PlatformBlock(
              icon: '🤖', title: 'Android / Samsung',
              steps: ['1. Chrome браузерт нээх',
                      '2. Дээр баруун ⋮ цэс',
                      '3. "Install app" эсвэл "Add to Home Screen"',
                      '4. "Install" дарах'],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformBlock extends StatelessWidget {
  final String icon, title;
  final List<String> steps;
  const _PlatformBlock({required this.icon, required this.title, required this.steps});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          ...steps.map((s) => Padding(
            padding: const EdgeInsets.only(left: 28, top: 2),
            child: Text(s, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          )),
        ],
      ),
    );
  }
}

class _NotificationsDialog extends StatelessWidget {
  const _NotificationsDialog();
  @override
  Widget build(BuildContext context) {
    final notes = [
      ('🎁', 'Бүртгүүлэхэд 50,000₮ бэлэг!', 'Имэйлээр баталгаажуулсны дараа автоматаар орно', '5 мин өмнө'),
      ('🔥', 'Champions League эхэллээ', 'Real Madrid vs Barcelona — өндөр odds!', '12 мин өмнө'),
      ('💰', '100% бонус — Эхний хадгаламж', 'Анхны deposit дээрээ 300,000₮ хүртэл', '1 цаг өмнө'),
      ('⚡', 'Аккумулятор бонус идэвхтэй', '5+ тоглолттой акк дээр +10%', '3 цаг өмнө'),
      ('🎮', 'Эспорт live тоглолт', 'CS2 IEM Katowice — одоо явагдаж байна', '4 цаг өмнө'),
    ];
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              const Icon(Icons.notifications, color: AppColors.accent, size: 22),
              const SizedBox(width: 8),
              const Text('МЭДЭГДЭЛ',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(color: AppColors.liveRed, borderRadius: BorderRadius.circular(8)),
                child: Text('${notes.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
              ),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                  onPressed: () => Navigator.pop(context)),
            ]),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView(
                shrinkWrap: true,
                children: notes.map((n) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.$1, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.$2, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(n.$3, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(n.$4, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsDialog extends StatelessWidget {
  const _StatsDialog();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 460,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              const Icon(Icons.bar_chart, color: AppColors.accent, size: 22),
              const SizedBox(width: 8),
              const Text('САЙТЫН СТАТИСТИК',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                  onPressed: () => Navigator.pop(context)),
            ]),
            const SizedBox(height: 12),
            _StatRow(label: 'Идэвхтэй live тоглолт', value: '276+', color: AppColors.liveRed),
            _StatRow(label: 'Спортын төрөл', value: '11', color: AppColors.accent),
            _StatRow(label: 'Эспортын тэмцээн', value: '16', color: AppColors.blueLight),
            _StatRow(label: 'Бүртгэлтэй хэрэглэгч', value: '${1200 + DateTime.now().day * 7}', color: AppColors.orange),
            _StatRow(label: 'Өнөөдөр тавьсан бооцоо', value: '${4800 + DateTime.now().hour * 23}', color: AppColors.accent),
            _StatRow(label: 'Хамгийн их хожилт (өчигдөр)', value: '4,500,000₮', color: AppColors.orange),
            _StatRow(label: 'Сайт ажилласан хугацаа', value: '99.7%', color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatRow({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
          Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w800)),
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
