class OddsOption {
  final String label;
  final double odds;
  bool isSelected;

  OddsOption({
    required this.label,
    required this.odds,
    this.isSelected = false,
  });

  OddsOption copyWith({bool? isSelected}) {
    return OddsOption(
      label: label,
      odds: odds,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class BetMarket {
  final String id;
  final String name;
  final List<OddsOption> options;

  BetMarket({required this.id, required this.name, required this.options});
}

class SportEvent {
  final String id;
  final String sportId;
  final String league;
  final String country;
  final String countryFlag;
  final String homeTeam;
  final String awayTeam;
  final String homeLogo;
  final String awayLogo;
  final DateTime startTime;
  final bool isLive;
  final int homeScore;
  final int awayScore;
  final String? minute;
  final String? period;
  final List<BetMarket> markets;
  final int totalMarkets;

  SportEvent({
    required this.id,
    required this.sportId,
    required this.league,
    required this.country,
    required this.countryFlag,
    required this.homeTeam,
    required this.awayTeam,
    this.homeLogo = '',
    this.awayLogo = '',
    required this.startTime,
    this.isLive = false,
    this.homeScore = 0,
    this.awayScore = 0,
    this.minute,
    this.period,
    required this.markets,
    this.totalMarkets = 50,
  });
}
