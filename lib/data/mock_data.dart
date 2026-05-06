import '../models/sport_event.dart';

List<SportEvent> getMockEvents() {
  final now = DateTime.now();
  return [
    // === THAILAND LIVE ===
    SportEvent(
      id: 'th1',
      sportId: 'football',
      league: 'Thai Premier League',
      country: 'Тайланд',
      countryFlag: '🇹🇭',
      homeTeam: 'Buriram United',
      awayTeam: 'BG Pathum United',
      startTime: now.subtract(const Duration(minutes: 34)),
      isLive: true,
      homeScore: 1,
      awayScore: 0,
      minute: '34',
      period: '1-р хагас',
      totalMarkets: 64,
      markets: [
        BetMarket(id: 'th1_1x2', name: '1X2', options: [
          OddsOption(label: '1', odds: 1.85),
          OddsOption(label: 'X', odds: 3.40),
          OddsOption(label: '2', odds: 4.20),
        ]),
        BetMarket(id: 'th1_ou', name: 'Нийт гол 2.5', options: [
          OddsOption(label: 'Дээш', odds: 1.70),
          OddsOption(label: 'Доош', odds: 2.10),
        ]),
        BetMarket(id: 'th1_bts', name: 'Хоёул гол оруулах уу', options: [
          OddsOption(label: 'Тийм', odds: 2.20),
          OddsOption(label: 'Үгүй', odds: 1.65),
        ]),
        BetMarket(id: 'th1_ah', name: 'Азийн хэрэглэл -0.5', options: [
          OddsOption(label: 'Buriram -0.5', odds: 1.72),
          OddsOption(label: 'BG +0.5', odds: 2.08),
        ]),
      ],
    ),
    SportEvent(
      id: 'th2',
      sportId: 'football',
      league: 'Thai Premier League',
      country: 'Тайланд',
      countryFlag: '🇹🇭',
      homeTeam: 'Muangthong United',
      awayTeam: 'Police Tero',
      startTime: now.subtract(const Duration(minutes: 62)),
      isLive: true,
      homeScore: 2,
      awayScore: 2,
      minute: '62',
      period: '2-р хагас',
      totalMarkets: 58,
      markets: [
        BetMarket(id: 'th2_1x2', name: '1X2', options: [
          OddsOption(label: '1', odds: 2.10),
          OddsOption(label: 'X', odds: 3.20),
          OddsOption(label: '2', odds: 3.40),
        ]),
        BetMarket(id: 'th2_ou', name: 'Нийт гол 4.5', options: [
          OddsOption(label: 'Дээш', odds: 2.60),
          OddsOption(label: 'Доош', odds: 1.45),
        ]),
        BetMarket(id: 'th2_bts', name: 'Хоёул гол оруулах уу', options: [
          OddsOption(label: 'Тийм', odds: 1.25),
          OddsOption(label: 'Үгүй', odds: 4.00),
        ]),
        BetMarket(id: 'th2_ah', name: 'Азийн хэрэглэл 0', options: [
          OddsOption(label: 'Muangthong', odds: 1.95),
          OddsOption(label: 'Police Tero', odds: 1.90),
        ]),
      ],
    ),
    SportEvent(
      id: 'th3',
      sportId: 'football',
      league: 'Thai Division 1',
      country: 'Тайланд',
      countryFlag: '🇹🇭',
      homeTeam: 'Chiang Rai United',
      awayTeam: 'Bangkok United',
      startTime: now.subtract(const Duration(minutes: 15)),
      isLive: true,
      homeScore: 0,
      awayScore: 1,
      minute: '15',
      period: '1-р хагас',
      totalMarkets: 52,
      markets: [
        BetMarket(id: 'th3_1x2', name: '1X2', options: [
          OddsOption(label: '1', odds: 3.10),
          OddsOption(label: 'X', odds: 3.30),
          OddsOption(label: '2', odds: 2.15),
        ]),
        BetMarket(id: 'th3_ou', name: 'Нийт гол 2.5', options: [
          OddsOption(label: 'Дээш', odds: 1.90),
          OddsOption(label: 'Доош', odds: 1.90),
        ]),
        BetMarket(id: 'th3_bts', name: 'Хоёул гол оруулах уу', options: [
          OddsOption(label: 'Тийм', odds: 2.00),
          OddsOption(label: 'Үгүй', odds: 1.75),
        ]),
        BetMarket(id: 'th3_ah', name: 'Азийн хэрэглэл +0.5', options: [
          OddsOption(label: 'Chiang Rai +0.5', odds: 2.20),
          OddsOption(label: 'Bangkok -0.5', odds: 1.66),
        ]),
      ],
    ),

    // === THAILAND UPCOMING ===
    SportEvent(
      id: 'th4',
      sportId: 'football',
      league: 'Thai Premier League',
      country: 'Тайланд',
      countryFlag: '🇹🇭',
      homeTeam: 'Port FC',
      awayTeam: 'Nakhon Ratchasima',
      startTime: now.add(const Duration(hours: 2, minutes: 30)),
      totalMarkets: 60,
      markets: [
        BetMarket(id: 'th4_1x2', name: '1X2', options: [
          OddsOption(label: '1', odds: 1.75),
          OddsOption(label: 'X', odds: 3.50),
          OddsOption(label: '2', odds: 4.50),
        ]),
        BetMarket(id: 'th4_ou', name: 'Нийт гол 2.5', options: [
          OddsOption(label: 'Дээш', odds: 1.80),
          OddsOption(label: 'Доош', odds: 2.00),
        ]),
        BetMarket(id: 'th4_bts', name: 'Хоёул гол оруулах уу', options: [
          OddsOption(label: 'Тийм', odds: 2.10),
          OddsOption(label: 'Үгүй', odds: 1.70),
        ]),
        BetMarket(id: 'th4_ah', name: 'Азийн хэрэглэл -1', options: [
          OddsOption(label: 'Port -1', odds: 1.85),
          OddsOption(label: 'Nakhon +1', odds: 1.95),
        ]),
        BetMarket(id: 'th4_cs', name: 'Зөв дүн', options: [
          OddsOption(label: '1-0', odds: 5.50),
          OddsOption(label: '2-0', odds: 7.00),
          OddsOption(label: '2-1', odds: 8.00),
          OddsOption(label: '1-1', odds: 6.00),
          OddsOption(label: '0-0', odds: 10.0),
        ]),
      ],
    ),
    SportEvent(
      id: 'th5',
      sportId: 'football',
      league: 'Thai Premier League',
      country: 'Тайланд',
      countryFlag: '🇹🇭',
      homeTeam: 'Ratchaburi',
      awayTeam: 'Suphanburi',
      startTime: now.add(const Duration(hours: 4)),
      totalMarkets: 48,
      markets: [
        BetMarket(id: 'th5_1x2', name: '1X2', options: [
          OddsOption(label: '1', odds: 2.30),
          OddsOption(label: 'X', odds: 3.10),
          OddsOption(label: '2', odds: 3.00),
        ]),
        BetMarket(id: 'th5_ou', name: 'Нийт гол 2.5', options: [
          OddsOption(label: 'Дээш', odds: 1.85),
          OddsOption(label: 'Доош', odds: 1.95),
        ]),
        BetMarket(id: 'th5_bts', name: 'Хоёул гол оруулах уу', options: [
          OddsOption(label: 'Тийм', odds: 2.05),
          OddsOption(label: 'Үгүй', odds: 1.72),
        ]),
        BetMarket(id: 'th5_ah', name: 'Азийн хэрэглэл 0', options: [
          OddsOption(label: 'Ratchaburi', odds: 2.05),
          OddsOption(label: 'Suphanburi', odds: 1.82),
        ]),
      ],
    ),

    // === PREMIER LEAGUE ===
    SportEvent(
      id: 'pl1',
      sportId: 'football',
      league: 'Premier League',
      country: 'Англи',
      countryFlag: '🏴󠁧󠁢󠁥󠁮󠁧󠁿',
      homeTeam: 'Manchester City',
      awayTeam: 'Arsenal',
      startTime: now.add(const Duration(hours: 1, minutes: 45)),
      totalMarkets: 85,
      markets: [
        BetMarket(id: 'pl1_1x2', name: '1X2', options: [
          OddsOption(label: '1', odds: 1.65),
          OddsOption(label: 'X', odds: 4.00),
          OddsOption(label: '2', odds: 5.00),
        ]),
        BetMarket(id: 'pl1_ou', name: 'Нийт гол 2.5', options: [
          OddsOption(label: 'Дээш', odds: 1.55),
          OddsOption(label: 'Доош', odds: 2.40),
        ]),
        BetMarket(id: 'pl1_bts', name: 'Хоёул гол оруулах уу', options: [
          OddsOption(label: 'Тийм', odds: 1.75),
          OddsOption(label: 'Үгүй', odds: 2.00),
        ]),
        BetMarket(id: 'pl1_ah', name: 'Азийн хэрэглэл -1', options: [
          OddsOption(label: 'Man City -1', odds: 2.00),
          OddsOption(label: 'Arsenal +1', odds: 1.85),
        ]),
        BetMarket(id: 'pl1_dnb', name: 'Draw No Bet', options: [
          OddsOption(label: 'Man City', odds: 1.35),
          OddsOption(label: 'Arsenal', odds: 3.20),
        ]),
      ],
    ),
    SportEvent(
      id: 'pl2',
      sportId: 'football',
      league: 'Premier League',
      country: 'Англи',
      countryFlag: '🏴󠁧󠁢󠁥󠁮󠁧󠁿',
      homeTeam: 'Liverpool',
      awayTeam: 'Chelsea',
      startTime: now.add(const Duration(hours: 3, minutes: 30)),
      isLive: true,
      homeScore: 2,
      awayScore: 1,
      minute: '71',
      period: '2-р хагас',
      totalMarkets: 80,
      markets: [
        BetMarket(id: 'pl2_1x2', name: '1X2', options: [
          OddsOption(label: '1', odds: 1.40),
          OddsOption(label: 'X', odds: 4.50),
          OddsOption(label: '2', odds: 7.50),
        ]),
        BetMarket(id: 'pl2_ou', name: 'Нийт гол 3.5', options: [
          OddsOption(label: 'Дээш', odds: 2.30),
          OddsOption(label: 'Доош', odds: 1.60),
        ]),
        BetMarket(id: 'pl2_bts', name: 'Хоёул гол оруулах уу', options: [
          OddsOption(label: 'Тийм', odds: 1.30),
          OddsOption(label: 'Үгүй', odds: 3.50),
        ]),
        BetMarket(id: 'pl2_ah', name: 'Азийн хэрэглэл -1.5', options: [
          OddsOption(label: 'Liverpool -1.5', odds: 2.80),
          OddsOption(label: 'Chelsea +1.5', odds: 1.45),
        ]),
      ],
    ),

    // === CHAMPIONS LEAGUE ===
    SportEvent(
      id: 'cl1',
      sportId: 'football',
      league: 'Champions League',
      country: 'Европ',
      countryFlag: '🌍',
      homeTeam: 'Real Madrid',
      awayTeam: 'Bayern Munich',
      startTime: now.add(const Duration(hours: 5)),
      totalMarkets: 90,
      markets: [
        BetMarket(id: 'cl1_1x2', name: '1X2', options: [
          OddsOption(label: '1', odds: 2.00),
          OddsOption(label: 'X', odds: 3.60),
          OddsOption(label: '2', odds: 3.50),
        ]),
        BetMarket(id: 'cl1_ou', name: 'Нийт гол 2.5', options: [
          OddsOption(label: 'Дээш', odds: 1.65),
          OddsOption(label: 'Доош', odds: 2.20),
        ]),
        BetMarket(id: 'cl1_bts', name: 'Хоёул гол оруулах уу', options: [
          OddsOption(label: 'Тийм', odds: 1.80),
          OddsOption(label: 'Үгүй', odds: 1.95),
        ]),
        BetMarket(id: 'cl1_ah', name: 'Азийн хэрэглэл 0', options: [
          OddsOption(label: 'Real Madrid', odds: 1.90),
          OddsOption(label: 'Bayern', odds: 1.92),
        ]),
        BetMarket(id: 'cl1_dnb', name: 'Draw No Bet', options: [
          OddsOption(label: 'Real Madrid', odds: 1.62),
          OddsOption(label: 'Bayern', odds: 2.30),
        ]),
      ],
    ),

    // === NBA BASKETBALL ===
    SportEvent(
      id: 'nba1',
      sportId: 'basketball',
      league: 'NBA',
      country: 'АНУ',
      countryFlag: '🇺🇸',
      homeTeam: 'LA Lakers',
      awayTeam: 'Golden State',
      startTime: now.add(const Duration(hours: 8)),
      totalMarkets: 45,
      markets: [
        BetMarket(id: 'nba1_ml', name: 'Монейлайн', options: [
          OddsOption(label: 'Lakers', odds: 1.85),
          OddsOption(label: 'Golden State', odds: 1.95),
        ]),
        BetMarket(id: 'nba1_spread', name: 'Хэрэглэл -3.5', options: [
          OddsOption(label: 'Lakers -3.5', odds: 1.90),
          OddsOption(label: 'Golden State +3.5', odds: 1.90),
        ]),
        BetMarket(id: 'nba1_ou', name: 'Нийт оноо 220.5', options: [
          OddsOption(label: 'Дээш', odds: 1.88),
          OddsOption(label: 'Доош', odds: 1.92),
        ]),
      ],
    ),
    SportEvent(
      id: 'nba2',
      sportId: 'basketball',
      league: 'NBA',
      country: 'АНУ',
      countryFlag: '🇺🇸',
      homeTeam: 'Boston Celtics',
      awayTeam: 'Miami Heat',
      startTime: now.subtract(const Duration(minutes: 28)),
      isLive: true,
      homeScore: 58,
      awayScore: 52,
      minute: 'Q3 4:22',
      totalMarkets: 42,
      markets: [
        BetMarket(id: 'nba2_ml', name: 'Монейлайн', options: [
          OddsOption(label: 'Celtics', odds: 1.45),
          OddsOption(label: 'Miami', odds: 2.65),
        ]),
        BetMarket(id: 'nba2_spread', name: 'Хэрэглэл', options: [
          OddsOption(label: 'Celtics -5.5', odds: 1.90),
          OddsOption(label: 'Miami +5.5', odds: 1.90),
        ]),
        BetMarket(id: 'nba2_ou', name: 'Нийт оноо 215.5', options: [
          OddsOption(label: 'Дээш', odds: 1.92),
          OddsOption(label: 'Доош', odds: 1.88),
        ]),
      ],
    ),

    // === TENNIS ===
    SportEvent(
      id: 'ten1',
      sportId: 'tennis',
      league: 'French Open',
      country: 'Франц',
      countryFlag: '🇫🇷',
      homeTeam: 'Novak Djokovic',
      awayTeam: 'Carlos Alcaraz',
      startTime: now.add(const Duration(hours: 2)),
      totalMarkets: 35,
      markets: [
        BetMarket(id: 'ten1_ml', name: 'Ялагч', options: [
          OddsOption(label: 'Djokovic', odds: 1.70),
          OddsOption(label: 'Alcaraz', odds: 2.10),
        ]),
        BetMarket(id: 'ten1_set', name: 'Нийт сет дээш/доош 3.5', options: [
          OddsOption(label: 'Дээш 3.5', odds: 2.20),
          OddsOption(label: 'Доош 3.5', odds: 1.62),
        ]),
        BetMarket(id: 'ten1_first', name: '1-р сет ялагч', options: [
          OddsOption(label: 'Djokovic', odds: 1.65),
          OddsOption(label: 'Alcaraz', odds: 2.20),
        ]),
      ],
    ),
    SportEvent(
      id: 'ten2',
      sportId: 'tennis',
      league: 'French Open',
      country: 'Франц',
      countryFlag: '🇫🇷',
      homeTeam: 'Iga Swiatek',
      awayTeam: 'Coco Gauff',
      startTime: now.subtract(const Duration(minutes: 45)),
      isLive: true,
      homeScore: 1,
      awayScore: 0,
      minute: '6-3, 3-2*',
      totalMarkets: 30,
      markets: [
        BetMarket(id: 'ten2_ml', name: 'Ялагч', options: [
          OddsOption(label: 'Swiatek', odds: 1.30),
          OddsOption(label: 'Gauff', odds: 3.60),
        ]),
        BetMarket(id: 'ten2_set', name: 'Нийт сет', options: [
          OddsOption(label: 'Дээш 2.5', odds: 2.80),
          OddsOption(label: 'Доош 2.5', odds: 1.42),
        ]),
      ],
    ),

    // === TABLE TENNIS ===
    SportEvent(
      id: 'tt1',
      sportId: 'tabletennis',
      league: 'ITTF World Tour',
      country: 'Хятад',
      countryFlag: '🇨🇳',
      homeTeam: 'Ma Long',
      awayTeam: 'Fan Zhendong',
      startTime: now.subtract(const Duration(minutes: 12)),
      isLive: true,
      homeScore: 2,
      awayScore: 1,
      minute: '4-р сет',
      totalMarkets: 22,
      markets: [
        BetMarket(id: 'tt1_ml', name: 'Ялагч', options: [
          OddsOption(label: 'Ma Long', odds: 1.90),
          OddsOption(label: 'Fan Zhendong', odds: 1.90),
        ]),
        BetMarket(id: 'tt1_sets', name: 'Нийт сет', options: [
          OddsOption(label: 'Дээш 4.5', odds: 2.05),
          OddsOption(label: 'Доош 4.5', odds: 1.75),
        ]),
      ],
    ),

    // === VOLLEYBALL ===
    SportEvent(
      id: 'vb1',
      sportId: 'volleyball',
      league: 'Thailand Volleyball League',
      country: 'Тайланд',
      countryFlag: '🇹🇭',
      homeTeam: 'Nakhon Ratchasima VC',
      awayTeam: 'Supreme Chonburi',
      startTime: now.subtract(const Duration(minutes: 55)),
      isLive: true,
      homeScore: 2,
      awayScore: 1,
      minute: '4-р сет 18-14',
      totalMarkets: 28,
      markets: [
        BetMarket(id: 'vb1_ml', name: 'Ялагч', options: [
          OddsOption(label: 'Nakhon Ratchasima', odds: 1.65),
          OddsOption(label: 'Supreme Chonburi', odds: 2.20),
        ]),
        BetMarket(id: 'vb1_sets', name: 'Нийт сет дээш/доош 3.5', options: [
          OddsOption(label: 'Дээш 3.5', odds: 1.80),
          OddsOption(label: 'Доош 3.5', odds: 2.00),
        ]),
      ],
    ),

    // === MMA / BOXING ===
    SportEvent(
      id: 'mma1',
      sportId: 'mma',
      league: 'ONE Championship',
      country: 'Тайланд',
      countryFlag: '🇹🇭',
      homeTeam: 'Stamp Fairtex',
      awayTeam: 'Angela Lee',
      startTime: now.add(const Duration(hours: 6)),
      totalMarkets: 20,
      markets: [
        BetMarket(id: 'mma1_ml', name: 'Ялагч', options: [
          OddsOption(label: 'Stamp Fairtex', odds: 1.85),
          OddsOption(label: 'Angela Lee', odds: 1.95),
        ]),
        BetMarket(id: 'mma1_method', name: 'Ялалтын арга', options: [
          OddsOption(label: 'KO/TKO', odds: 2.80),
          OddsOption(label: 'Submission', odds: 3.20),
          OddsOption(label: 'Decision', odds: 2.40),
        ]),
        BetMarket(id: 'mma1_round', name: 'Раунд дэмждэг уу', options: [
          OddsOption(label: 'Тийм', odds: 1.80),
          OddsOption(label: 'Үгүй', odds: 1.95),
        ]),
      ],
    ),

    // === E-SPORTS ===
    SportEvent(
      id: 'es1',
      sportId: 'esports',
      league: 'ESL Pro League - CS2',
      country: 'Олон улс',
      countryFlag: '🌍',
      homeTeam: 'Natus Vincere',
      awayTeam: 'Team Vitality',
      startTime: now.add(const Duration(hours: 1)),
      totalMarkets: 30,
      markets: [
        BetMarket(id: 'es1_ml', name: 'Ялагч', options: [
          OddsOption(label: 'NAVI', odds: 2.10),
          OddsOption(label: 'Vitality', odds: 1.72),
        ]),
        BetMarket(id: 'es1_maps', name: 'Нийт газрын зураг', options: [
          OddsOption(label: '2 газрын зураг', odds: 1.60),
          OddsOption(label: '3 газрын зураг', odds: 2.20),
        ]),
        BetMarket(id: 'es1_first', name: '1-р газрын зураг ялагч', options: [
          OddsOption(label: 'NAVI', odds: 2.05),
          OddsOption(label: 'Vitality', odds: 1.80),
        ]),
      ],
    ),
    SportEvent(
      id: 'es2',
      sportId: 'esports',
      league: 'LCK - League of Legends',
      country: 'Солонгос',
      countryFlag: '🇰🇷',
      homeTeam: 'T1',
      awayTeam: 'Gen.G',
      startTime: now.subtract(const Duration(minutes: 25)),
      isLive: true,
      homeScore: 1,
      awayScore: 0,
      minute: '2-р тоглолт 22:45',
      totalMarkets: 25,
      markets: [
        BetMarket(id: 'es2_ml', name: 'Ялагч', options: [
          OddsOption(label: 'T1', odds: 1.50),
          OddsOption(label: 'Gen.G', odds: 2.60),
        ]),
        BetMarket(id: 'es2_games', name: 'Нийт тоглолт', options: [
          OddsOption(label: '2 тоглолт', odds: 2.00),
          OddsOption(label: '3 тоглолт', odds: 1.80),
        ]),
      ],
    ),

    // === BADMINTON ===
    SportEvent(
      id: 'bd1',
      sportId: 'badminton',
      league: 'BWF World Tour',
      country: 'Тайланд',
      countryFlag: '🇹🇭',
      homeTeam: 'Kunlavut Vitidsarn',
      awayTeam: 'Viktor Axelsen',
      startTime: now.subtract(const Duration(minutes: 18)),
      isLive: true,
      homeScore: 1,
      awayScore: 1,
      minute: '3-р сет 12-10*',
      totalMarkets: 18,
      markets: [
        BetMarket(id: 'bd1_ml', name: 'Ялагч', options: [
          OddsOption(label: 'Vitidsarn', odds: 2.80),
          OddsOption(label: 'Axelsen', odds: 1.45),
        ]),
        BetMarket(id: 'bd1_sets', name: 'Нийт сет', options: [
          OddsOption(label: 'Дээш 2.5', odds: 1.75),
          OddsOption(label: 'Доош 2.5', odds: 2.05),
        ]),
      ],
    ),
  ];
}

List<SportEvent> getLiveEvents() =>
    getMockEvents().where((e) => e.isLive).toList();

List<SportEvent> getEventsBySport(String sportId) =>
    getMockEvents().where((e) => e.sportId == sportId).toList();

List<SportEvent> getFeaturedEvents() {
  final all = getMockEvents();
  return [
    ...all.where((e) => e.isLive).take(3),
    ...all.where((e) => !e.isLive).take(4),
  ];
}
