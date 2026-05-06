import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/sport.dart';

class SportCategoryRow extends StatefulWidget {
  final String selectedId;
  final ValueChanged<String> onSelected;

  const SportCategoryRow({
    super.key,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  State<SportCategoryRow> createState() => _SportCategoryRowState();
}

class _SportCategoryRowState extends State<SportCategoryRow> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: allSports.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final sport = allSports[index];
          final isSelected = sport.id == widget.selectedId;
          return GestureDetector(
            onTap: () => widget.onSelected(sport.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.orange : AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.orange
                      : AppColors.divider,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(sport.emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sport.name,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (sport.liveCount > 0)
                        Row(
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: AppColors.liveRed,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${sport.liveCount} live',
                              style: const TextStyle(
                                color: AppColors.liveRed,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
