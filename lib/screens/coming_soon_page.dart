import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ComingSoonPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String subtitle;

  const ComingSoonPage({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle = 'Удахгүй нээгдэх болно',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.blueDark, AppColors.blue],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(icon, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(title,
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent),
              ),
              child: Text(subtitle,
                  style: const TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 32),
            Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Icon(Icons.construction, size: 36, color: AppColors.orange),
                  const SizedBox(height: 12),
                  const Text(
                    'Энэ хэсэг хөгжүүлэлтэд байна',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Та одоогоор Спорт, Лайв, Профайл хэсгүүдэд бүрэн хандах боломжтой.',
                    style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
