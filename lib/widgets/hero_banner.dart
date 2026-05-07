import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import 'auth_dialog.dart';

class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 700;
    if (isMobile) return _buildMobile(context);
    return Container(
      height: 180,
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 6),
      child: Row(
        children: [
          // Left: Welcome bonus
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E5A99), Color(0xFF22B14C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text('ШИНЭ ХЭРЭГЛЭГЧИЙН БОНУС',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 12),
                  const Text('100% БОНУС',
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1.0)),
                  const SizedBox(height: 4),
                  const Text('Эхний хадгаламж дээрээ 300,000₮ хүртэл',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 14),
                  Builder(
                    builder: (ctx) => InkWell(
                      onTap: () {
                        if (AuthService.isLoggedIn) {
                          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                            backgroundColor: AppColors.accent,
                            content: Text('🎁 Та бонус авах эрхгүй — энэ нь зөвхөн шинэ хэрэглэгчдэд'),
                            behavior: SnackBarBehavior.floating,
                          ));
                        } else {
                          showDialog(context: ctx, builder: (_) => const AuthDialog(startOnRegister: true));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('БОНУС АВАХ',
                            style: TextStyle(color: AppColors.blueDark, fontSize: 12, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Middle: Live highlight (Stadium-themed)
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A2540), Color(0xFF1A2C42), Color(0xFF15497F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(color: AppColors.blue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Stack(
                children: [
                  // Stadium-line decoration
                  Positioned(
                    top: 0, right: 0, bottom: 0,
                    child: Opacity(
                      opacity: 0.08,
                      child: Container(
                        width: 130,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage('https://cdn-icons-png.flaticon.com/256/2965/2965287.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.liveRed,
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: [
                                  BoxShadow(color: AppColors.liveRed.withOpacity(0.6), blurRadius: 8),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.circle, color: Colors.white, size: 7),
                                  SizedBox(width: 4),
                                  Text('LIVE',
                                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('🏆',
                                style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            const Text('UEFA Champions League',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _Team('Barcelona', '🔵', Color(0xFF004D98), 'https://logo.clearbit.com/fcbarcelona.com'),
                            Column(
                              children: [
                                const Text('LIVE',
                                    style: TextStyle(color: AppColors.liveRed, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
                                const SizedBox(height: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.accent, width: 1.5),
                                    boxShadow: [
                                      BoxShadow(color: AppColors.accent.withOpacity(0.4), blurRadius: 8),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text('1', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                                      SizedBox(width: 6),
                                      Text(':', style: TextStyle(color: AppColors.textMuted, fontSize: 18, fontWeight: FontWeight.w700)),
                                      SizedBox(width: 6),
                                      Text('0', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.liveRed.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: const Text("67'",
                                      style: TextStyle(color: AppColors.liveRed, fontSize: 10, fontWeight: FontWeight.w800)),
                                ),
                              ],
                            ),
                            _Team('Shakhtar', '🟠', Color(0xFFFF6600), 'https://logo.clearbit.com/shakhtar.com'),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            _MiniOdds('1', '1.85'),
                            const SizedBox(width: 4),
                            _MiniOdds('X', '3.20'),
                            const SizedBox(width: 4),
                            _MiniOdds('2', '4.50'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Right: Mobile app promo
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF15497F), Color(0xFF0E1B2C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(color: AppColors.accent.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [AppColors.orange, AppColors.liveRed]),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text('🎁 + 50,000₮',
                              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(height: 8),
                        ShaderMask(
                          shaderCallback: (b) => const LinearGradient(
                            colors: [Colors.white, Color(0xFFFFD700)],
                          ).createShader(b),
                          child: const Text('МОБИЛ АПП',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                        ),
                        const SizedBox(height: 4),
                        const Text('QR код уншуул',
                            style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _AppBadge(Icons.apple, 'iOS'),
                            const SizedBox(width: 6),
                            _AppBadge(Icons.android, 'Android'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 86, height: 86,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 12, spreadRadius: 1),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Image.network(
                      'https://api.qrserver.com/v1/create-qr-code/?size=120x120&data=https://sportbet-mn.onrender.com&color=0E1B2C&bgcolor=ffffff',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.qr_code_2, size: 78, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Container(
      height: 110,
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E5A99), Color(0xFF22B14C)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text('БОНУС',
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 8),
                const Text('100% БОНУС',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, height: 1)),
                const SizedBox(height: 2),
                const Text('Эхний хадгаламж 300,000₮ хүртэл',
                    style: TextStyle(color: Colors.white, fontSize: 11)),
              ],
            ),
          ),
          Builder(
            builder: (ctx) => InkWell(
              onTap: () {
                if (!AuthService.isLoggedIn) {
                  showDialog(context: ctx, builder: (_) => const AuthDialog(startOnRegister: true));
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('АВАХ',
                    style: TextStyle(color: AppColors.blueDark, fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Team extends StatelessWidget {
  final String name;
  final String emoji;
  final Color color;
  final String? logoUrl;
  const _Team(this.name, this.emoji, this.color, [this.logoUrl]);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 10, spreadRadius: 1)],
          ),
          padding: const EdgeInsets.all(4),
          child: logoUrl != null
              ? Image.network(logoUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ))
              : Container(
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
        ),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _AppBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _AppBadge(this.icon, this.label);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 3),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _MiniOdds extends StatelessWidget {
  final String label, odds;
  const _MiniOdds(this.label, this.odds);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.surfaceHov, AppColors.surface],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(odds, style: const TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
