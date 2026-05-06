class Sport {
  final String id;
  final String name;
  final String emoji;
  final int eventCount;
  final int liveCount;

  const Sport({
    required this.id,
    required this.name,
    required this.emoji,
    required this.eventCount,
    required this.liveCount,
  });
}

final List<Sport> allSports = [
  Sport(id: 'football', name: 'Хөлбөмбөг', emoji: '⚽', eventCount: 248, liveCount: 12),
  Sport(id: 'basketball', name: 'Сагсан бөмбөг', emoji: '🏀', eventCount: 86, liveCount: 5),
  Sport(id: 'tennis', name: 'Теннис', emoji: '🎾', eventCount: 124, liveCount: 8),
  Sport(id: 'volleyball', name: 'Волейбол', emoji: '🏐', eventCount: 42, liveCount: 3),
  Sport(id: 'boxing', name: 'Бокс', emoji: '🥊', eventCount: 18, liveCount: 0),
  Sport(id: 'mma', name: 'MMA', emoji: '🥋', eventCount: 24, liveCount: 1),
  Sport(id: 'baseball', name: 'Бейсбол', emoji: '⚾', eventCount: 56, liveCount: 4),
  Sport(id: 'hockey', name: 'Хоккей', emoji: '🏒', eventCount: 38, liveCount: 2),
  Sport(id: 'cricket', name: 'Крикет', emoji: '🏏', eventCount: 22, liveCount: 1),
  Sport(id: 'rugby', name: 'Регби', emoji: '🏉', eventCount: 16, liveCount: 0),
  Sport(id: 'badminton', name: 'Бадминтон', emoji: '🏸', eventCount: 34, liveCount: 2),
  Sport(id: 'tabletennis', name: 'Ширээний теннис', emoji: '🏓', eventCount: 68, liveCount: 6),
  Sport(id: 'esports', name: 'Е-спорт', emoji: '🎮', eventCount: 44, liveCount: 3),
  Sport(id: 'snooker', name: 'Снукер', emoji: '🎱', eventCount: 12, liveCount: 0),
  Sport(id: 'handball', name: 'Гар бөмбөг', emoji: '🤾', eventCount: 28, liveCount: 1),
  Sport(id: 'cycling', name: 'Дугуй унах', emoji: '🚴', eventCount: 8, liveCount: 0),
  Sport(id: 'golf', name: 'Гольф', emoji: '⛳', eventCount: 14, liveCount: 0),
  Sport(id: 'americanfootball', name: 'Америк хөлбөмбөг', emoji: '🏈', eventCount: 22, liveCount: 0),
];
