const express = require('express');
const cors = require('cors');

const app = express();
const PORT = 3001;

app.use(cors());
app.use(express.json());

// ==================== STATE ====================
let balance = 50000.0;
let transactions = [];

// Live match state - auto-updates every 30s
let liveMatches = [
  {
    id: 'th1', sportId: 'football',
    league: 'Thai Premier League', country: 'Тайланд', countryFlag: '🇹🇭',
    homeTeam: 'Buriram United', awayTeam: 'BG Pathum United',
    isLive: true, homeScore: 1, awayScore: 0,
    minute: 34, minuteStr: "34", period: '1-р хагас', totalMarkets: 64,
    markets: [
      { id: 'th1_1x2', name: '1X2', options: [
        { label: '1', odds: 1.85 }, { label: 'X', odds: 3.40 }, { label: '2', odds: 4.20 }
      ]},
      { id: 'th1_ou', name: 'Нийт гол 2.5', options: [
        { label: 'Дээш', odds: 1.70 }, { label: 'Доош', odds: 2.10 }
      ]},
      { id: 'th1_bts', name: 'Хоёул гол оруулах уу', options: [
        { label: 'Тийм', odds: 2.20 }, { label: 'Үгүй', odds: 1.65 }
      ]},
    ]
  },
  {
    id: 'th2', sportId: 'football',
    league: 'Thai Premier League', country: 'Тайланд', countryFlag: '🇹🇭',
    homeTeam: 'Muangthong United', awayTeam: 'Police Tero',
    isLive: true, homeScore: 2, awayScore: 2,
    minute: 62, minuteStr: "62", period: '2-р хагас', totalMarkets: 58,
    markets: [
      { id: 'th2_1x2', name: '1X2', options: [
        { label: '1', odds: 2.10 }, { label: 'X', odds: 3.20 }, { label: '2', odds: 3.40 }
      ]},
      { id: 'th2_ou', name: 'Нийт гол 4.5', options: [
        { label: 'Дээш', odds: 2.60 }, { label: 'Доош', odds: 1.45 }
      ]},
      { id: 'th2_bts', name: 'Хоёул гол оруулах уу', options: [
        { label: 'Тийм', odds: 1.25 }, { label: 'Үгүй', odds: 4.00 }
      ]},
    ]
  },
  {
    id: 'pl2', sportId: 'football',
    league: 'Premier League', country: 'Англи', countryFlag: '🏴󠁧󠁢󠁥󠁮󠁧󠁿',
    homeTeam: 'Liverpool', awayTeam: 'Chelsea',
    isLive: true, homeScore: 2, awayScore: 1,
    minute: 71, minuteStr: "71", period: '2-р хагас', totalMarkets: 80,
    markets: [
      { id: 'pl2_1x2', name: '1X2', options: [
        { label: '1', odds: 1.40 }, { label: 'X', odds: 4.50 }, { label: '2', odds: 7.50 }
      ]},
      { id: 'pl2_ou', name: 'Нийт гол 3.5', options: [
        { label: 'Дээш', odds: 2.30 }, { label: 'Доош', odds: 1.60 }
      ]},
      { id: 'pl2_bts', name: 'Хоёул гол оруулах уу', options: [
        { label: 'Тийм', odds: 1.30 }, { label: 'Үгүй', odds: 3.50 }
      ]},
    ]
  },
  {
    id: 'nba2', sportId: 'basketball',
    league: 'NBA', country: 'АНУ', countryFlag: '🇺🇸',
    homeTeam: 'Boston Celtics', awayTeam: 'Miami Heat',
    isLive: true, homeScore: 58, awayScore: 52,
    minute: 0, minuteStr: "Q3 4:22", period: 'Q3', totalMarkets: 42,
    markets: [
      { id: 'nba2_ml', name: 'Монейлайн', options: [
        { label: 'Celtics', odds: 1.45 }, { label: 'Miami', odds: 2.65 }
      ]},
      { id: 'nba2_ou', name: 'Нийт оноо 215.5', options: [
        { label: 'Дээш', odds: 1.92 }, { label: 'Доош', odds: 1.88 }
      ]},
    ]
  },
  {
    id: 'ten2', sportId: 'tennis',
    league: 'French Open', country: 'Франц', countryFlag: '🇫🇷',
    homeTeam: 'Iga Swiatek', awayTeam: 'Coco Gauff',
    isLive: true, homeScore: 1, awayScore: 0,
    minute: 0, minuteStr: "6-3, 3-2*", period: '2-р сет', totalMarkets: 30,
    markets: [
      { id: 'ten2_ml', name: 'Ялагч', options: [
        { label: 'Swiatek', odds: 1.30 }, { label: 'Gauff', odds: 3.60 }
      ]},
    ]
  },
  {
    id: 'es2', sportId: 'esports',
    league: 'LCK - League of Legends', country: 'Солонгос', countryFlag: '🇰🇷',
    homeTeam: 'T1', awayTeam: 'Gen.G',
    isLive: true, homeScore: 1, awayScore: 0,
    minute: 0, minuteStr: "Game 2 22:45", period: '2-р тоглолт', totalMarkets: 25,
    markets: [
      { id: 'es2_ml', name: 'Ялагч', options: [
        { label: 'T1', odds: 1.50 }, { label: 'Gen.G', odds: 2.60 }
      ]},
    ]
  },
  {
    id: 'bd1', sportId: 'badminton',
    league: 'BWF World Tour', country: 'Тайланд', countryFlag: '🇹🇭',
    homeTeam: 'Kunlavut Vitidsarn', awayTeam: 'Viktor Axelsen',
    isLive: true, homeScore: 1, awayScore: 1,
    minute: 0, minuteStr: "3-р сет 12-10*", period: '3-р сет', totalMarkets: 18,
    markets: [
      { id: 'bd1_ml', name: 'Ялагч', options: [
        { label: 'Vitidsarn', odds: 2.80 }, { label: 'Axelsen', odds: 1.45 }
      ]},
    ]
  },
  {
    id: 'tt1', sportId: 'tabletennis',
    league: 'ITTF World Tour', country: 'Хятад', countryFlag: '🇨🇳',
    homeTeam: 'Ma Long', awayTeam: 'Fan Zhendong',
    isLive: true, homeScore: 2, awayScore: 1,
    minute: 0, minuteStr: "4-р сет", period: '4-р сет', totalMarkets: 22,
    markets: [
      { id: 'tt1_ml', name: 'Ялагч', options: [
        { label: 'Ma Long', odds: 1.90 }, { label: 'Fan Zhendong', odds: 1.90 }
      ]},
    ]
  },
];

let upcomingMatches = [
  {
    id: 'th4', sportId: 'football',
    league: 'Thai Premier League', country: 'Тайланд', countryFlag: '🇹🇭',
    homeTeam: 'Port FC', awayTeam: 'Nakhon Ratchasima',
    isLive: false, homeScore: 0, awayScore: 0,
    minute: null, minuteStr: null, period: null, totalMarkets: 60,
    startOffsetHours: 2.5,
    markets: [
      { id: 'th4_1x2', name: '1X2', options: [
        { label: '1', odds: 1.75 }, { label: 'X', odds: 3.50 }, { label: '2', odds: 4.50 }
      ]},
      { id: 'th4_ou', name: 'Нийт гол 2.5', options: [
        { label: 'Дээш', odds: 1.80 }, { label: 'Доош', odds: 2.00 }
      ]},
    ]
  },
  {
    id: 'pl1', sportId: 'football',
    league: 'Premier League', country: 'Англи', countryFlag: '🏴󠁧󠁢󠁥󠁮󠁧󠁿',
    homeTeam: 'Manchester City', awayTeam: 'Arsenal',
    isLive: false, homeScore: 0, awayScore: 0,
    minute: null, minuteStr: null, period: null, totalMarkets: 85,
    startOffsetHours: 1.75,
    markets: [
      { id: 'pl1_1x2', name: '1X2', options: [
        { label: '1', odds: 1.65 }, { label: 'X', odds: 4.00 }, { label: '2', odds: 5.00 }
      ]},
      { id: 'pl1_ou', name: 'Нийт гол 2.5', options: [
        { label: 'Дээш', odds: 1.55 }, { label: 'Доош', odds: 2.40 }
      ]},
    ]
  },
  {
    id: 'cl1', sportId: 'football',
    league: 'Champions League', country: 'Европ', countryFlag: '🌍',
    homeTeam: 'Real Madrid', awayTeam: 'Bayern Munich',
    isLive: false, homeScore: 0, awayScore: 0,
    minute: null, minuteStr: null, period: null, totalMarkets: 90,
    startOffsetHours: 5,
    markets: [
      { id: 'cl1_1x2', name: '1X2', options: [
        { label: '1', odds: 2.00 }, { label: 'X', odds: 3.60 }, { label: '2', odds: 3.50 }
      ]},
      { id: 'cl1_bts', name: 'Хоёул гол оруулах уу', options: [
        { label: 'Тийм', odds: 1.80 }, { label: 'Үгүй', odds: 1.95 }
      ]},
    ]
  },
  {
    id: 'nba1', sportId: 'basketball',
    league: 'NBA', country: 'АНУ', countryFlag: '🇺🇸',
    homeTeam: 'LA Lakers', awayTeam: 'Golden State',
    isLive: false, homeScore: 0, awayScore: 0,
    minute: null, minuteStr: null, period: null, totalMarkets: 45,
    startOffsetHours: 8,
    markets: [
      { id: 'nba1_ml', name: 'Монейлайн', options: [
        { label: 'Lakers', odds: 1.85 }, { label: 'Golden State', odds: 1.95 }
      ]},
    ]
  },
  {
    id: 'ten1', sportId: 'tennis',
    league: 'French Open', country: 'Франц', countryFlag: '🇫🇷',
    homeTeam: 'Novak Djokovic', awayTeam: 'Carlos Alcaraz',
    isLive: false, homeScore: 0, awayScore: 0,
    minute: null, minuteStr: null, period: null, totalMarkets: 35,
    startOffsetHours: 2,
    markets: [
      { id: 'ten1_ml', name: 'Ялагч', options: [
        { label: 'Djokovic', odds: 1.70 }, { label: 'Alcaraz', odds: 2.10 }
      ]},
    ]
  },
  {
    id: 'mma1', sportId: 'mma',
    league: 'ONE Championship', country: 'Тайланд', countryFlag: '🇹🇭',
    homeTeam: 'Stamp Fairtex', awayTeam: 'Angela Lee',
    isLive: false, homeScore: 0, awayScore: 0,
    minute: null, minuteStr: null, period: null, totalMarkets: 20,
    startOffsetHours: 6,
    markets: [
      { id: 'mma1_ml', name: 'Ялагч', options: [
        { label: 'Stamp Fairtex', odds: 1.85 }, { label: 'Angela Lee', odds: 1.95 }
      ]},
    ]
  },
];

// ==================== LIVE SCORE SIMULATION ====================
function clamp(val, min, max) {
  return Math.min(Math.max(val, min), max);
}

function randomBetween(a, b) {
  return a + Math.random() * (b - a);
}

function updateOdds(match) {
  const diff = match.homeScore - match.awayScore;
  const market1x2 = match.markets.find(m => m.id.includes('1x2'));
  if (market1x2) {
    if (diff > 0) {
      market1x2.options[0].odds = clamp(market1x2.options[0].odds - randomBetween(0.05, 0.15), 1.10, 10.0);
      market1x2.options[2].odds = clamp(market1x2.options[2].odds + randomBetween(0.10, 0.25), 1.10, 20.0);
    } else if (diff < 0) {
      market1x2.options[0].odds = clamp(market1x2.options[0].odds + randomBetween(0.10, 0.25), 1.10, 20.0);
      market1x2.options[2].odds = clamp(market1x2.options[2].odds - randomBetween(0.05, 0.15), 1.10, 10.0);
    }
    market1x2.options.forEach(o => {
      o.odds = Math.round(o.odds * 100) / 100;
    });
  }
}

// Update live matches every 30 seconds
setInterval(() => {
  liveMatches.forEach(match => {
    if (!match.isLive) return;

    // Football - update minute
    if (match.sportId === 'football' && match.minute !== null) {
      match.minute = Math.min(match.minute + 1, 90);
      match.minuteStr = String(match.minute);
      if (match.minute <= 45) match.period = '1-р хагас';
      else match.period = '2-р хагас';

      // 4% chance of goal per 30s
      if (Math.random() < 0.04) {
        if (Math.random() < 0.55) match.homeScore++;
        else match.awayScore++;
        updateOdds(match);
        console.log(`⚽ GOAL! ${match.homeTeam} ${match.homeScore}-${match.awayScore} ${match.awayTeam}`);
      }

      // Finish match at 90
      if (match.minute >= 90) {
        match.isLive = false;
        console.log(`🏁 Match ended: ${match.homeTeam} ${match.homeScore}-${match.awayScore} ${match.awayTeam}`);
      }
    }

    // Basketball - random score increment
    if (match.sportId === 'basketball') {
      const pts = Math.floor(Math.random() * 3);
      if (pts > 0) {
        if (Math.random() < 0.55) match.homeScore += pts;
        else match.awayScore += pts;
      }
    }
  });
}, 30000);

// ==================== HELPERS ====================
function buildEventResponse(match, nowMs) {
  const startOffsetMs = (match.startOffsetHours || 0) * 3600000;
  const startTime = match.isLive
    ? new Date(nowMs - (match.minute || 0) * 60000).toISOString()
    : new Date(nowMs + startOffsetMs).toISOString();
  return {
    ...match,
    startTime,
  };
}

// ==================== ROUTES ====================
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Balance
app.get('/api/balance', (req, res) => {
  res.json({ balance, currency: 'MNT' });
});

// Deposit
app.post('/api/deposit', (req, res) => {
  const { amount } = req.body;
  if (!amount || typeof amount !== 'number' || amount <= 0) {
    return res.status(400).json({ error: 'Буруу дүн оруулсан байна' });
  }
  if (amount > 10000000) {
    return res.status(400).json({ error: 'Нэг удаад 10,000,000₮-с илүүгүй орц нэмнэ' });
  }
  balance += amount;
  const tx = {
    id: `tx_${Date.now()}`,
    type: 'deposit',
    amount,
    balance,
    timestamp: new Date().toISOString(),
    note: 'Орц нэмсэн'
  };
  transactions.unshift(tx);
  console.log(`💰 Deposit: +₮${amount.toLocaleString()} → Balance: ₮${balance.toLocaleString()}`);
  res.json({ success: true, balance, amount, transaction: tx });
});

// Withdraw
app.post('/api/withdraw', (req, res) => {
  const { amount } = req.body;
  if (!amount || typeof amount !== 'number' || amount <= 0) {
    return res.status(400).json({ error: 'Буруу дүн оруулсан байна' });
  }
  if (amount > balance) {
    return res.status(400).json({ error: 'Үлдэгдэл хүрэлцэхгүй байна' });
  }
  if (amount < 1000) {
    return res.status(400).json({ error: 'Хамгийн багадаа 1,000₮ гаргана' });
  }
  balance -= amount;
  const tx = {
    id: `tx_${Date.now()}`,
    type: 'withdraw',
    amount,
    balance,
    timestamp: new Date().toISOString(),
    note: 'Гарц авсан'
  };
  transactions.unshift(tx);
  console.log(`💸 Withdraw: -₮${amount.toLocaleString()} → Balance: ₮${balance.toLocaleString()}`);
  res.json({ success: true, balance, amount, transaction: tx });
});

// Transaction history
app.get('/api/transactions', (req, res) => {
  res.json({ transactions: transactions.slice(0, 50) });
});

// Live events
app.get('/api/live-events', (req, res) => {
  const now = Date.now();
  const events = liveMatches
    .filter(m => m.isLive)
    .map(m => buildEventResponse(m, now));
  res.json({ events, count: events.length, updatedAt: new Date().toISOString() });
});

// Upcoming events
app.get('/api/upcoming-events', (req, res) => {
  const now = Date.now();
  const sport = req.query.sport;
  let events = upcomingMatches.map(m => buildEventResponse(m, now));
  if (sport) events = events.filter(e => e.sportId === sport);
  res.json({ events, count: events.length });
});

// All events
app.get('/api/events', (req, res) => {
  const now = Date.now();
  const sport = req.query.sport;
  let all = [
    ...liveMatches.map(m => buildEventResponse(m, now)),
    ...upcomingMatches.map(m => buildEventResponse(m, now)),
  ];
  if (sport) all = all.filter(e => e.sportId === sport);
  res.json({ events: all, count: all.length });
});

app.listen(PORT, () => {
  console.log(`\n🚀 SportBet MN Backend: http://localhost:${PORT}`);
  console.log(`📡 Live events: http://localhost:${PORT}/api/live-events`);
  console.log(`💰 Balance:     http://localhost:${PORT}/api/balance\n`);
});
