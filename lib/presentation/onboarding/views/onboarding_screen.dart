import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/views/login_screen.dart';
import '../../auth/views/signup_screen.dart';
import '../../shared/widgets/luma_logo.dart';

class OnboardingItem {
  final String imagePath;
  final String titleEn;
  final String titleId;
  final String subtitleEn;
  final String subtitleId;

  const OnboardingItem({
    required this.imagePath,
    required this.titleEn,
    required this.titleId,
    required this.subtitleEn,
    required this.subtitleId,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isIndonesian = false;

  final List<OnboardingItem> _slides = const [
    OnboardingItem(
      imagePath: 'assets/images/slider_1.png',
      titleEn: 'Welcome to Luma!',
      titleId: 'Selamat Datang di Luma!',
      subtitleEn:
          'The ultimate app for making your daily learning as convenient and smooth as possible',
      subtitleId:
          'Aplikasi terbaik untuk membuat proses belajar harian Anda lebih mudah, terstruktur, dan menyenangkan',
    ),
    OnboardingItem(
      imagePath: 'assets/images/slider_2.png',
      titleEn: 'Learn from the Best',
      titleId: 'Belajar dari Mentor Terbaik',
      subtitleEn:
          'Stream high quality interactive video lessons anytime and master real-world skills at your own pace',
      subtitleId:
          'Access quality interactive learning videos anytime and master real skills at your own pace',
    ),
    OnboardingItem(
      imagePath: 'assets/images/slider_3.png',
      titleEn: 'Track Your Growth',
      titleId: 'Pantau Progres Belajarmu',
      subtitleEn:
          'Monitor your milestones, evaluate your knowledge with quizzes, and achieve certified success',
      subtitleId:
          'Pantau pencapaian Anda, uji pemahaman lewat kuis interaktif, dan raih sertifikat kompetensi',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToSignUp() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const SignUpScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _toggleLanguage() {
    setState(() {
      _isIndonesian = !_isIndonesian;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar (Logo on left, Language badge on right)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const LumaLogo(
                      size: LumaLogoSize.small,
                    ),
                    InkWell(
                      onTap: _toggleLanguage,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.tertiary,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.outline,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.translate_rounded,
                              size: 13,
                              color: AppTheme.neutral,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _isIndonesian ? 'Indonesia' : 'English',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.heading,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 14,
                              color: AppTheme.neutral,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page Slider
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(flex: 1),
                          // Freepik Vector Illustration
                          SizedBox(
                            height: 250,
                            child: Image.asset(
                              slide.imagePath,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: AppTheme.tertiary,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Icon(
                                  Icons.school_rounded,
                                  size: 72,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(flex: 1),

                          // Title
                          Text(
                            _isIndonesian ? slide.titleId : slide.titleEn,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.heading,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Subtitle
                          Text(
                            _isIndonesian
                                ? slide.subtitleId
                                : slide.subtitleEn,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.neutral,
                              height: 1.5,
                            ),
                          ),
                          const Spacer(flex: 1),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Page Indicator (Active pill, inactive small circles)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (index) {
                  final isActive = index == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3.5),
                    height: 5.5,
                    width: isActive ? 24.0 : 5.5,
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.primary : AppTheme.outline,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 28),

              // Bottom Actions (Primary blue pill button + Signup link)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _navigateToLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: AppTheme.primary.withOpacity(0.35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: Text(
                          _isIndonesian
                              ? 'Akses Akun Anda'
                              : 'Access Your Account',
                          style: GoogleFonts.poppins(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Don't have an account? Signup
                    GestureDetector(
                      onTap: _navigateToSignUp,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              color: AppTheme.neutral,
                            ),
                            children: [
                              TextSpan(
                                text: _isIndonesian
                                    ? 'Belum punya akun? '
                                    : "Don't have an account? ",
                              ),
                              TextSpan(
                                text: 'Signup',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
