import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'data/bet_provider.dart';
import 'screens/app_shell.dart';
import 'services/auth_service.dart';

void main() {
  AuthService.loadFromStorage();
  runApp(
    ChangeNotifierProvider(
      create: (_) => BetProvider(),
      child: const SportBetApp(),
    ),
  );
}

class SportBetApp extends StatelessWidget {
  const SportBetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SportBet MN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.orange,
          secondary: AppColors.blue,
          surface: AppColors.surface,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: AppColors.textSecondary),
          bodyLarge: TextStyle(color: Colors.white),
        ),
        scrollbarTheme: const ScrollbarThemeData(
          thumbColor: WidgetStatePropertyAll(AppColors.divider),
        ),
      ),
      home: const AppShell(),
    );
  }
}
