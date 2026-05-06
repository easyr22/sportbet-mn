class BetItem {
  final String id;
  final String eventId;
  final String homeTeam;
  final String awayTeam;
  final String league;
  final String marketName;
  final String optionLabel;
  final double odds;

  const BetItem({
    required this.id,
    required this.eventId,
    required this.homeTeam,
    required this.awayTeam,
    required this.league,
    required this.marketName,
    required this.optionLabel,
    required this.odds,
  });
}

enum BetSlipMode { single, accumulator }
