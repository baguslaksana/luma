import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma/core/theme/app_theme.dart';
import 'package:luma/domain/entities/user.dart';
import 'package:luma/presentation/auth/providers/auth_provider.dart';
import 'package:luma/presentation/auth/views/login_screen.dart';
import 'package:luma/presentation/course_list/providers/course_list_provider.dart';
import 'package:luma/presentation/settings/views/settings_screen.dart';
import 'package:luma/presentation/teacher/views/teacher_courses_screen.dart';

class ProfileScreen extends ConsumerWidget {
  final ValueChanged<int>? onNavigateTab;

  const ProfileScreen({
    super.key,
    this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isPengajar = currentUser?.role == UserRole.pengajar;
    final coursesAsync = ref.watch(coursesProvider);
    final coursesCount = coursesAsync.value?.length ?? 0;
    final lessonsCount = coursesAsync.value?.fold<int>(0, (sum, c) => sum + c.lessons.length) ?? 0;

    return Scaffold(
      backgroundColor: AppTheme.appBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Bar: Header Judul + Settings Shortcut ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isPengajar ? 'Teacher Profile' : 'My Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.heading,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.outline),
                      ),
                      child: const Icon(
                        Icons.settings_outlined,
                        color: AppTheme.heading,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── 1. User Info Header Card ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.outline),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.tertiary,
                        border: Border.all(color: AppTheme.primary, width: 2.5),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppTheme.primary,
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentUser?.name ?? 'Luma User',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.heading,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentUser?.email ?? 'user@luma.id',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: AppTheme.bodyText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Role Badge Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: isPengajar
                            ? const Color(0xFFFEF3C7)
                            : AppTheme.softBlue,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: isPengajar
                              ? const Color(0xFFF59E0B).withValues(alpha: 0.3)
                              : AppTheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPengajar
                                ? Icons.verified_rounded
                                : Icons.school_rounded,
                            size: 13,
                            color: isPengajar
                                ? const Color(0xFFD97706)
                                : AppTheme.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isPengajar
                                ? 'Verified High School Teacher'
                                : 'High School Student • Grade 12',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isPengajar
                                  ? const Color(0xFFD97706)
                                  : AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quick Stats Ribbon untuk Siswa
                    if (!isPengajar) ...[
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStudentMiniStat('$coursesCount', 'Courses', Icons.auto_stories_rounded, AppTheme.primary),
                          Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
                          _buildStudentMiniStat(coursesCount > 0 ? '${coursesCount * 2} Hrs' : '0 Hrs', 'Study Time', Icons.access_time_rounded, const Color(0xFFD97706)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // ── Stats Card khusus Pengajar (2 Cards) ──
              if (isPengajar) ...[
                _buildTeacherStats(coursesCount, lessonsCount),
                const SizedBox(height: 22),
              ],

              // ── 2. ORGANIZED MENU SECTIONS ──
              if (!isPengajar) ...[
                // ── SECTION 1: LEARNING ACTIVITY ──
                _buildSectionLabel('Learning Activity'),
                const SizedBox(height: 8),
                _buildGroupedCard([
                  _GroupedTileItem(
                    icon: Icons.pie_chart_rounded,
                    iconBgColor: AppTheme.softBlue,
                    iconColor: AppTheme.primary,
                    title: 'My Learning Progress',
                    subtitle: 'Check course & module completion percentage',
                    onTap: () {
                      if (onNavigateTab != null) onNavigateTab!(2);
                    },
                  ),
                ]),
                const SizedBox(height: 20),

                // ── SECTION 2: SETTINGS & HELP ──
                _buildSectionLabel('Settings & Help'),
                const SizedBox(height: 8),
                _buildGroupedCard([
                  _GroupedTileItem(
                    icon: Icons.settings_rounded,
                    iconBgColor: const Color(0xFFF1F5F9),
                    iconColor: AppTheme.heading,
                    title: 'Account Settings',
                    subtitle: 'Password, notifications & preferences',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                  _GroupedTileItem(
                    icon: Icons.help_center_rounded,
                    iconBgColor: const Color(0xFFE0F2FE),
                    iconColor: const Color(0xFF0284C7),
                    title: 'Help Center & FAQ',
                    subtitle: 'App usage support & troubleshooting',
                    onTap: () {
                      _showInfoDialog(
                        context,
                        'Student Help Center',
                        'For general questions and technical issues, contact support@luma.id or reach out to your tutor through your class.',
                      );
                    },
                  ),
                  _GroupedTileItem(
                    icon: Icons.info_rounded,
                    iconBgColor: const Color(0xFFF3E8FF),
                    iconColor: const Color(0xFF9333EA),
                    title: 'About Luma',
                    subtitle: 'Version 1.0.0 • E-Learning Platform',
                    onTap: () {
                      _showInfoDialog(
                        context,
                        'About Luma',
                        'Luma E-Learning Platform v1.0.0\nLearning, Understand, Master, Achieve.',
                      );
                    },
                  ),
                ]),
              ] else ...[
                // ── TEACHER SECTION ──
                _buildSectionLabel('Courses & Teaching'),
                const SizedBox(height: 8),
                _buildGroupedCard([
                  _GroupedTileItem(
                    icon: Icons.menu_book_rounded,
                    iconBgColor: AppTheme.softBlue,
                    iconColor: AppTheme.primary,
                    title: 'Manage Courses & Lessons',
                    subtitle: 'View, add, or update course materials',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TeacherCoursesScreen(),
                        ),
                      );
                    },
                  ),
                  _GroupedTileItem(
                    icon: Icons.verified_user_rounded,
                    iconBgColor: const Color(0xFFFEF3C7),
                    iconColor: const Color(0xFFD97706),
                    title: 'Teacher Certification & ID',
                    subtitle: 'Educator status information',
                    onTap: () {
                      _showInfoDialog(
                        context,
                        'Educator Information',
                        'Name: ${currentUser?.name ?? "Drs. Bambang Sudarsono, M.Pd."}\nID: 19780512 200312 1 002\nStatus: Verified Senior High School Teacher\nAffiliation: Luma E-Learning',
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 20),

                _buildSectionLabel('Preferences & Support'),
                const SizedBox(height: 8),
                _buildGroupedCard([
                  _GroupedTileItem(
                    icon: Icons.settings_rounded,
                    iconBgColor: const Color(0xFFF1F5F9),
                    iconColor: AppTheme.heading,
                    title: 'Teacher Account Settings',
                    subtitle: 'Profile settings and password',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                  _GroupedTileItem(
                    icon: Icons.support_agent_rounded,
                    iconBgColor: const Color(0xFFE0F2FE),
                    iconColor: const Color(0xFF0284C7),
                    title: 'Help Center & Curriculum',
                    subtitle: 'Curriculum services and LMS guide',
                    onTap: () {
                      _showInfoDialog(
                        context,
                        'Teacher Help Center',
                        'Curriculum support & Luma LMS technical assistance: guru@luma.edu / WhatsApp +62 812-3456-7890.',
                      );
                    },
                  ),
                  _GroupedTileItem(
                    icon: Icons.info_rounded,
                    iconBgColor: const Color(0xFFF3E8FF),
                    iconColor: const Color(0xFF9333EA),
                    title: 'About Luma',
                    subtitle: 'Version 1.0.0 • Teacher & Student Portal',
                    onTap: () {
                      _showInfoDialog(
                        context,
                        'About Luma',
                        'Luma E-Learning Platform v1.0.0\nInteractive Teaching & Learning Portal.',
                      );
                    },
                  ),
                ]),
              ],
              const SizedBox(height: 28),

              // ── 3. Sign Out Button ──
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showLogoutConfirmation(context, ref);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.2),
                    backgroundColor: const Color(0xFFFEF2F2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(
                    Icons.logout_rounded,
                    size: 18,
                    color: Color(0xFFDC2626),
                  ),
                  label: Text(
                    'Sign Out',
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── WIDGET HELPER: SECTION LABEL ──
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF475569),
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  // ── WIDGET HELPER: GROUPED CARD ──
  Widget _buildGroupedCard(List<_GroupedTileItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            indent: 64,
            endIndent: 16,
            color: Color(0xFFF1F5F9),
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: item.onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: item.iconBgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.icon,
                          color: item.iconColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.heading,
                              ),
                            ),
                            if (item.subtitle != null) ...[
                              const SizedBox(height: 1),
                              Text(
                                item.subtitle!,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppTheme.bodyText,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFCBD5E1),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── WIDGET HELPER: STUDENT MINI STAT ──
  Widget _buildStudentMiniStat(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.heading,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            color: AppTheme.bodyText,
          ),
        ),
      ],
    );
  }

  // ── WIDGET HELPER: TEACHER STATS ──
  Widget _buildTeacherStats(int coursesCount, int lessonsCount) {
    return Row(
      children: [
        _buildTeacherStatCard(
          icon: Icons.menu_book_rounded,
          value: '$coursesCount',
          label: 'Assigned Courses',
          color: AppTheme.primary,
        ),
        const SizedBox(width: 12),
        _buildTeacherStatCard(
          icon: Icons.play_circle_outline_rounded,
          value: '$lessonsCount',
          label: 'Lesson Videos',
          color: const Color(0xFF7C3AED),
        ),
      ],
    );
  }

  Widget _buildTeacherStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.heading,
          ),
        ),
        content: Text(
          content,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppTheme.bodyText,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Confirm Sign Out',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.heading,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out of your Luma account?',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppTheme.bodyText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppTheme.neutral,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: Text(
              'Sign Out',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupedTileItem {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _GroupedTileItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}
