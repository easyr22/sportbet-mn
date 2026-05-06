import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class _SportEntry {
  final String id, emoji, name;
  final int live, total;
  const _SportEntry(this.id, this.emoji, this.name, this.live, this.total);
}

const _sports = [
  _SportEntry('all',           '🌐', 'Бүгд',            27, 89),
  _SportEntry('football',      '⚽', 'Хөлбөмбөг',       12, 42),
  _SportEntry('basketball',    '🏀', 'Баскетбол',         4, 18),
  _SportEntry('tennis',        '🎾', 'Теннис',            3, 12),
  _SportEntry('esports',       '🎮', 'Кибер спорт',       2,  8),
  _SportEntry('badminton',     '🏸', 'Бадминтон',         1,  5),
  _SportEntry('tabletennis',   '🏓', 'Ширээний теннис',   1,  4),
  _SportEntry('volleyball',    '🏐', 'Волейбол',          0,  3),
  _SportEntry('mma',           '🥊', 'ДХТ / ММА',         0,  2),
  _SportEntry('hockey',        '🏒', 'Хоккей',            0,  6),
  _SportEntry('americanfootball','🏈','Америк хөл',        0,  3),
];

class LeftSidebar extends StatelessWidget {
  final String selectedSport;
  final ValueChanged<String> onSportSelected;
  final bool showLive;

  const LeftSidebar({
    super.key,
    required this.selectedSport,
    required this.onSportSelected,
    required this.showLive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      color: AppColors.sidebar,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: _sports.map((s) => _SportTile(
          entry: s,
          selected: selectedSport == s.id,
          onTap: () => onSportSelected(s.id),
          showLive: showLive,
        )).toList(),
      ),
    );
  }
}

class _SportTile extends StatelessWidget {
  final _SportEntry entry;
  final bool selected, showLive;
  final VoidCallback onTap;

  const _SportTile({required this.entry, required this.selected, required this.onTap, required this.showLive});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.orange.withOpacity(0.08) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: selected ? AppColors.orange : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(entry.emoji, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                entry.name,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (entry.live > 0)
              Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.liveRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.liveRed.withOpacity(0.5)),
                ),
                child: Text(
                  '${entry.live}',
                  style: const TextStyle(color: AppColors.liveRed, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: selected ? AppColors.orange : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${entry.total}',
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
