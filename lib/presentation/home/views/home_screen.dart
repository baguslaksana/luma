import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/user.dart';
import '../../auth/providers/auth_provider.dart';
import '../../course_detail/views/course_detail_screen.dart';
import '../../course_list/providers/course_list_provider.dart';
import '../../shared/widgets/skeleton_loader.dart';
import '../../teacher/views/add_edit_course_screen.dart';
import '../../teacher/views/teacher_courses_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const HomeScreen({
    super.key,
    this.onNavigateTab,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategorySlugProvider);
    final currentUser = ref.watch(currentUserProvider);
    final isPengajar = currentUser?.role == UserRole.pengajar;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: () async {
            ref.invalidate(coursesProvider);
            await ref.read(coursesProvider.future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header: Avatar + Welcome + Role Badge + Notification Bell
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.tertiary,
                      border: Border.all(color: AppTheme.outline),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppTheme.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.neutral,
                          ),
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                currentUser?.name ?? 'User',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.heading,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Role pill badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isPengajar
                                    ? const Color(0xFFFEF3C7)
                                    : AppTheme.tertiary,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPengajar
                                        ? Icons.verified_rounded
                                        : Icons.school_rounded,
                                    size: 11,
                                    color: isPengajar
                                        ? const Color(0xFFD97706)
                                        : AppTheme.primary,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    isPengajar ? 'Teacher' : 'Student',
                                    style: GoogleFonts.poppins(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: isPengajar
                                          ? const Color(0xFFD97706)
                                          : AppTheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Search Bar + Filter Icon Button
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.outline),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          ref.read(searchQueryProvider.notifier).state = value;
                        },
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppTheme.heading,
                        ),
                        decoration: InputDecoration(
                          hintText: isPengajar
                              ? 'Search your assigned courses...'
                              : 'Search subjects or high school courses...',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: AppTheme.neutral,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppTheme.neutral,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.outline),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.tune_rounded,
                        color: AppTheme.heading,
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Category Chips Row
              categoriesAsync.when(
                data: (categories) {
                  return SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = cat.slug == selectedCategory;

                        return InkWell(
                          onTap: () {
                            ref.read(selectedCategorySlugProvider.notifier).state = cat.slug;
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primary : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppTheme.primary : AppTheme.outline,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.primary.withValues(alpha: 0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              cat.name,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected ? Colors.white : AppTheme.heading,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const SizedBox(height: 38),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 20),

              // 4. Featured Banner Card (Role-specific)
              _buildBannerCard(isPengajar, coursesAsync),
              const SizedBox(height: 24),

              // 5. Section Header (Role-specific)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isPengajar ? 'Assigned Courses' : 'Featured Courses',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.heading,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (isPengajar) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TeacherCoursesScreen(),
                          ),
                        );
                      } else {
                        widget.onNavigateTab?.call(1);
                      }
                    },
                    child: Text(
                      'See all',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 6. Horizontal Courses List
              coursesAsync.when(
                data: (courses) {
                  if (courses.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPengajar
                                  ? Icons.auto_stories_outlined
                                  : Icons.school_outlined,
                              size: 40,
                              color: AppTheme.neutral,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isPengajar
                                  ? 'No assigned courses yet.'
                                  : 'No courses available yet.',
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.heading,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isPengajar
                                  ? 'Tap "Create Course & Upload Video" below to add your first course!'
                                  : 'Courses uploaded by your teacher will appear here automatically.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                color: AppTheme.neutral,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 232,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: courses.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final course = courses[index];

                        // Assign high-resolution Freepik illustrations
                        String localAsset;
                        if (course.category.slug == 'matematika' ||
                            course.id.contains('matematika')) {
                          localAsset = 'assets/images/course_math.png';
                        } else if (course.category.slug == 'bahasa' ||
                            course.id.contains('literasi')) {
                          localAsset = 'assets/images/course_literasi.png';
                        } else if (course.id.contains('utbk')) {
                          localAsset = 'assets/images/home_banner_sma.png';
                        } else {
                          localAsset = 'assets/images/course_science.png';
                        }

                        // Duration string
                        final hours = course.totalDurationSeconds ~/ 3600;
                        final minutes = (course.totalDurationSeconds % 3600) ~/ 60;
                        final durationStr = hours > 0
                            ? '${course.level} | ${hours}h ${minutes}m'
                            : '${course.level} | ${minutes}m';

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CourseDetailScreen(
                                  courseId: course.id,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 205,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppTheme.outline),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Thumbnail Container
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(17),
                                  ),
                                  child: Container(
                                    height: 112,
                                    width: double.infinity,
                                    color: AppTheme.tertiary,
                                    padding: const EdgeInsets.all(8),
                                    child: Image.asset(
                                      localAsset,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Image.network(
                                        course.thumbnailUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        course.title,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.heading,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        course.category.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11.5,
                                          color: AppTheme.neutral,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        durationStr,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.neutral,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => SizedBox(
                  height: 232,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (_, __) => const SizedBox(
                      width: 200,
                      child: CourseCardHorizontalSkeleton(),
                    ),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // 7. Pengajar only: "Tambah Materi Baru" action section
              if (isPengajar) ...[
                const SizedBox(height: 28),
                _buildTeacherActionSection(),
              ],
            ],
          ),
        ),
        ),
      ),
    );
  }

  /// Role-based featured banner card
  Widget _buildBannerCard(bool isPengajar, AsyncValue<List<Course>> coursesAsync) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPengajar
              ? [const Color(0xFF0E7490), const Color(0xFF06B6D4)]
              : [const Color(0xFF1D4ED8), const Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isPengajar ? const Color(0xFF0E7490) : AppTheme.primary)
                .withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    height: 130,
                    child: Image.asset(
                      isPengajar
                          ? 'assets/images/home_banner_sma.png'
                          : 'assets/images/home_banner_sma.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/slider_1.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isPengajar
                              ? 'Teacher & Instructor Studio'
                              : 'Intensive College Prep 2026',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          isPengajar
                              ? 'Manage courses, upload lessons, and create interactive learning.'
                              : 'Master college entrance exams with expert tutors and targeted mock tests.',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            if (isPengajar) {
                              _openAddCourseScreen();
                            } else {
                              final available = coursesAsync.value;
                              if (available != null && available.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CourseDetailScreen(
                                      courseId: available.first.id,
                                    ),
                                  ),
                                );
                              } else {
                                widget.onNavigateTab?.call(1);
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isPengajar ? 'Create Course' : 'Start Learning',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: isPengajar
                                    ? const Color(0xFF0E7490)
                                    : AppTheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Teacher-only action section: full-width card to add new material (no overflow)
  Widget _buildTeacherActionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manage Learning',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.heading,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _openAddCourseScreen,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.tertiary,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.25),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Course & Upload Video',
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.heading,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Upload syllabus and lesson videos for students.',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppTheme.neutral,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppTheme.primary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Open add course screen
  void _openAddCourseScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditCourseScreen(),
      ),
    );
  }
}
