import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'presentation/achievement/views/achievement_screen.dart';
import 'presentation/auth/views/login_screen.dart';
import 'presentation/auth/views/signup_screen.dart';
import 'presentation/course_list/views/course_list_screen.dart';
import 'presentation/navigation/main_navigation_screen.dart';
import 'presentation/onboarding/views/onboarding_screen.dart';
import 'presentation/quiz/views/quiz_screen.dart';
import 'presentation/settings/views/settings_screen.dart';
import 'presentation/splash/views/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Service Locator (DataSources, Repositories, UseCases)
  ServiceLocator.setup();

  // 2. Jalankan aplikasi dengan ProviderScope Riverpod
  runApp(
    const ProviderScope(
      child: LumaApp(),
    ),
  );
}

class LumaApp extends StatelessWidget {
  const LumaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luma',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/main': (context) => const MainNavigationScreen(),
        '/courses': (context) => const CourseListScreen(),
        '/quiz': (context) => const QuizScreen(),
        '/achievement': (context) => const AchievementScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
