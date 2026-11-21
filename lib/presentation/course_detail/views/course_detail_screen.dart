import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/user.dart';
import '../../auth/providers/auth_provider.dart';
import '../../course_list/providers/course_list_provider.dart';
import '../../shared/widgets/skeleton_loader.dart';
import '../../shared/widgets/state_views.dart';
import '../../teacher/views/add_lesson_screen.dart';
import '../../video_player/views/video_player_screen.dart';
import '../providers/course_detail_provider.dart';
import '../widgets/instructor_card.dart';
import '../widgets/lesson_tile.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String courseId;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
  });

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseDetailProvider(widget.courseId));
    final currentUser = ref.watch(currentUserProvider);
    final isPengajar = currentUser?.role == UserRole.pengajar;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: courseAsync.when(
          data: (course) {
            if (course == null) {
              return const Center(child: Text('Course not found'));
            }

            final currentLesson =
                course.lessons.isNotEmpty ? course.lessons.first : null;

            // Compute total sections/duration label
            final hours = course.totalDurationSeconds ~/ 3600;
            final minutes = (course.totalDurationSeconds % 3600) ~/ 60;
            final durationStr = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
            final sectionsInfo = '${course.lessons.length} Chapters | $durationStr';

            // Select Freepik PNG illustration based on subject
            String localAsset;
            if (course.category.slug == 'matematika' || course.id.contains('matematika')) {
              localAsset = 'assets/images/course_math.png';
            } else if (course.category.slug == 'bahasa' || course.id.contains('literasi')) {
              localAsset = 'assets/images/course_literasi.png';
            } else if (course.id.contains('utbk')) {
              localAsset = 'assets/images/home_banner_sma.png';
            } else {
              localAsset = 'assets/images/course_science.png';
            }

            return Column(
              children: [
                // 1. Top Section: Media Viewport Banner with Play Button Overlay
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        color: AppTheme.tertiary,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Image.asset(
                                localAsset,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.network(
                                  course.thumbnailUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Play Button Overlay
                            if (course.lessons.isNotEmpty)
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => VideoPlayerScreen(
                                          initialLesson: currentLesson ?? course.lessons.first,
                                          playlist: course.lessons,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primary
                                              .withValues(alpha: 0.35),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 34,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Top Floating Buttons: Back Button & Heart Button
                    Positioned(
                        top: 14,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back Button
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: AppTheme.heading,
                                  size: 16,
                                ),
                              ),
                            ),
                            // Favorite Button
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isFavorite = !_isFavorite;
                                });
                              },
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: _isFavorite
                                      ? AppTheme.tertiary
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: _isFavorite
                                      ? AppTheme.primary
                                      : AppTheme.neutral,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                // 2. Course Details Body (Scrollable Content)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          course.title,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.heading,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Subtitle: Kategori / Jenjang SMA
                        Text(
                          '${course.category.name} • ${course.level}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppTheme.neutral,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Sections & Duration Line
                        Row(
                          children: [
                            const Icon(
                              Icons.play_circle_outline_rounded,
                              size: 16,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              sectionsInfo,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.neutral,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Section: Pengajar / Mentor
                        Text(
                          'Instructor',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.heading,
                          ),
                        ),
                        const SizedBox(height: 10),
                        InstructorCard(instructor: course.instructor),
                        const SizedBox(height: 20),

                        // Section: Deskripsi
                        Text(
                          'Course Description',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.heading,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          course.description,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.neutral,
                            height: 1.55,
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Section: Daftar Materi
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Curriculum',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.heading,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isPengajar) ...[
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddLessonScreen(
                                        courseId: course.id,
                                        courseTitle: course.title,
                                        nextOrder: course.lessons.length + 1,
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.add_rounded,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Add Lesson',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.tertiary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${course.lessons.length} Bab',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Lessons List
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: course.lessons.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final lesson = course.lessons[index];
                            final isPlaying = lesson.id == currentLesson?.id;

                            if (!isPengajar) {
                              return LessonTile(
                                lesson: lesson,
                                index: index,
                                isCurrentPlaying: isPlaying,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VideoPlayerScreen(
                                        initialLesson: lesson,
                                        playlist: course.lessons,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }

                            // Pengajar view with swipe-to-delete or delete action
                            return Dismissible(
                              key: Key(lesson.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: AppTheme.error,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              confirmDismiss: (dir) async {
                                return await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Lesson?'),
                                    content: Text('Delete "${lesson.title}" from this course?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.error,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (_) async {
                                await ServiceLocator.deleteLessonUseCase.execute(course.id, lesson.id);
                                ref.invalidate(courseDetailProvider(course.id));
                                ref.invalidate(coursesProvider);
                              },
                              child: LessonTile(
                                lesson: lesson,
                                index: index,
                                isCurrentPlaying: isPlaying,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VideoPlayerScreen(
                                        initialLesson: lesson,
                                        playlist: course.lessons,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: CourseDetailSkeleton(),
            ),
          ),
          error: (_, __) => ErrorStateView(
            onRetry: () => ref.invalidate(courseDetailProvider(widget.courseId)),
          ),
        ),
      ),
    );
  }
}
