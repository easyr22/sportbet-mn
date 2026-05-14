import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../data/bet_provider.dart';
import '../widgets/top_bar.dart';
import '../widgets/left_sidebar.dart';
import '../widgets/bet_slip_panel.dart';
import 'matches_page.dart';
import 'new_profile_page.dart';
import 'coming_soon_page.dart';
import 'casino_page.dart';
import 'promo_page.dart';
import 'bingo_page.dart';
import 'toto_page.dart';
import 'tv_games_page.dart';
import 'results_page.dart';
import 'ai_chat_screen.dart';
import '../widgets/winners_ticker.dart';
import '../widgets/win_popup.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _page = 0;           // 0=sports  1=live  2=profile
  String _sport = 'all';

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final wide   = w >= 1100;
    final medium = w >= 700;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: WinPopupOverlay(
        child: Column(
          children: [
            TopBar(
              currentPage: _page,
              onPageChanged: (p) => setState(() {
                _page = p;
                if (p != 0 && p != 1) _sport = 'all';
              }),
            ),
            const WinnersTicker(),
            Expanded(child: _buildBody(wide, medium)),
          ],
        ),
      ),
      floatingActionButton: !wide && _page < 2 ? _BetFab() : null,
    );
  }

  Widget _buildBody(bool wide, bool medium) {
    // Profile page
    if (_page == 2) return const ProfilePage();

    // Esports-only page (filter to esports)
    if (_page == 3) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (medium)
            LeftSidebar(
              selectedSport: 'esports',
              onSportSelected: (_) {},
              showLive: false,
            ),
          const Expanded(child: MatchesPage(sportFilter: 'esports', liveOnly: false)),
          if (wide) const BetSlipPanel(),
        ],
      );
    }

    // Casino / Live Casino / Promo / TV / Bingo / TOTO
    if (_page == 4) return const CasinoPage(isLive: false);
    if (_page == 5) return const CasinoPage(isLive: true);
    if (_page == 6) return const PromoPage();
    if (_page == 7) return const TvGamesPage();
    if (_page == 8) return const BingoPage();
    if (_page == 9) return const TotoPage();
    if (_page == 10) return const ResultsPage();
    if (_page == 11) return const AiChatScreen();

    // Default: Sports / Live
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (medium)
          LeftSidebar(
            selectedSport: _sport,
            onSportSelected: (s) => setState(() => _sport = s),
            showLive: _page == 1,
          ),
        Expanded(
          child: MatchesPage(
            sportFilter: _sport,
            liveOnly: _page == 1,
          ),
        ),
        if (wide) const BetSlipPanel(),
      ],
    );
  }
}

class _BetFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BetProvider>(
      builder: (_, prov, __) {
        if (prov.betCount == 0) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          backgroundColor: AppColors.orange,
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: const BetSlipPanel(),
            ),
          ),
          icon: const Icon(Icons.receipt_long, size: 18),
          label: Text(
            '${prov.betCount} бет  ×${prov.totalOdds.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}
