import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luma/core/theme/app_theme.dart';
import 'package:luma/domain/entities/user.dart';
import 'package:luma/presentation/auth/providers/auth_provider.dart';
import 'package:luma/presentation/course_list/views/course_list_screen.dart';
import 'package:luma/presentation/home/views/home_screen.dart';
import 'package:luma/presentation/profile/views/profile_screen.dart';
import 'package:luma/presentation/progress/views/progress_screen.dart';
import 'package:luma/presentation/teacher/views/teacher_courses_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isPengajar = currentUser?.role == UserRole.pengajar;

    // Halaman khusus untuk masing-masing role (Pengajar: 3 tab, Siswa: 4 tab)
    final List<Widget> pages = isPengajar
        ? [
            HomeScreen(onNavigateTab: _onTabTapped),
            const TeacherCoursesScreen(),
            ProfileScreen(onNavigateTab: _onTabTapped),
          ]
        : [
            HomeScreen(onNavigateTab: _onTabTapped),
            const CourseListScreen(),
            const ProgressScreen(),
            ProfileScreen(onNavigateTab: _onTabTapped),
          ];

    final activeIndex = _currentIndex >= pages.length ? 0 : _currentIndex;

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: activeIndex,
        children: pages,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
          child: Container(
            height: 66,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: isPengajar
                  ? [
                      _SmoothNavItem(
                        index: 0,
                        currentIndex: activeIndex,
                        activeIcon: Icons.dashboard_rounded,
                        inactiveIcon: Icons.dashboard_outlined,
                        tooltip: 'Dashboard',
                        onTap: _onTabTapped,
                      ),
                      _SmoothNavItem(
                        index: 1,
                        currentIndex: activeIndex,
                        activeIcon: Icons.auto_stories_rounded,
                        inactiveIcon: Icons.auto_stories_outlined,
                        tooltip: 'Courses',
                        onTap: _onTabTapped,
                      ),
                      _SmoothNavItem(
                        index: 2,
                        currentIndex: activeIndex,
                        activeIcon: Icons.person_rounded,
                        inactiveIcon: Icons.person_outline_rounded,
                        tooltip: 'Profile',
                        onTap: _onTabTapped,
                      ),
                    ]
                  : [
                      _SmoothNavItem(
                        index: 0,
                        currentIndex: activeIndex,
                        activeIcon: Icons.dashboard_rounded,
                        inactiveIcon: Icons.dashboard_outlined,
                        tooltip: 'Dashboard',
                        onTap: _onTabTapped,
                      ),
                      _SmoothNavItem(
                        index: 1,
                        currentIndex: activeIndex,
                        activeIcon: Icons.auto_stories_rounded,
                        inactiveIcon: Icons.auto_stories_outlined,
                        tooltip: 'Courses',
                        onTap: _onTabTapped,
                      ),
                      _SmoothNavItem(
                        index: 2,
                        currentIndex: activeIndex,
                        activeIcon: Icons.bookmark_rounded,
                        inactiveIcon: Icons.bookmark_outline_rounded,
                        tooltip: 'Progress',
                        onTap: _onTabTapped,
                      ),
                      _SmoothNavItem(
                        index: 3,
                        currentIndex: activeIndex,
                        activeIcon: Icons.person_rounded,
                        inactiveIcon: Icons.person_outline_rounded,
                        tooltip: 'Profile',
                        onTap: _onTabTapped,
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Instant responsive & smooth tactile navigation tab item
class _SmoothNavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String tooltip;
  final ValueChanged<int> onTap;

  const _SmoothNavItem({
    required this.index,
    required this.currentIndex,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap(index);
          },
          borderRadius: BorderRadius.circular(24),
          splashColor: AppTheme.primary.withValues(alpha: 0.12),
          highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: isSelected ? 54 : 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [
                        Color(0xFF1D4ED8),
                        Color(0xFF2563EB),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: AnimatedScale(
                scale: isSelected ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutBack,
                child: Icon(
                  isSelected ? activeIcon : inactiveIcon,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                  size: isSelected ? 23 : 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
