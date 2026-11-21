import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/lesson.dart';
import '../../course_detail/providers/course_detail_provider.dart';
import '../../course_detail/widgets/lesson_tile.dart';
import '../../shared/widgets/app_buttons.dart';
import '../../shared/widgets/skeleton_loader.dart';
import '../providers/video_player_notifier.dart';
import '../widgets/custom_player_controls.dart';
import '../widgets/lesson_playlist_sheet.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final Lesson initialLesson;
  final List<Lesson> playlist;

  const VideoPlayerScreen({
    super.key,
    required this.initialLesson,
    required this.playlist,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  YoutubePlayerController? _youtubeController;
  String? _currentYoutubeId;

  @override
  void initState() {
    super.initState();
    _setupYoutube(widget.initialLesson.videoUrl);
    // Memulai pemutaran video secara aman setelah frame pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(videoPlayerNotifierProvider.notifier)
          .initializeLesson(widget.initialLesson);
    });
  }

  void _setupYoutube(String url) {
    final ytId = YoutubePlayerController.convertUrlToId(url);
    if (ytId != null && ytId != _currentYoutubeId) {
      _currentYoutubeId = ytId;
      _youtubeController?.close();
      _youtubeController = YoutubePlayerController.fromVideoId(
        videoId: ytId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showFullscreenButton: true,
          mute: false,
        ),
      );
    } else if (ytId == null) {
      _currentYoutubeId = null;
      _youtubeController?.close();
      _youtubeController = null;
    }
  }

  @override
  void dispose() {
    _youtubeController?.close();
    super.dispose();
  }

  void _openPlaylistBottomSheet(String activeLessonId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LessonPlaylistSheet(
        playlist: widget.playlist,
        activeLessonId: activeLessonId,
        onSelectLesson: (newLesson) {
          setState(() {
            _setupYoutube(newLesson.videoUrl);
          });
          ref
              .read(videoPlayerNotifierProvider.notifier)
              .initializeLesson(newLesson);
        },
      ),
    );
  }

  void _toggleMarkLessonCompleted(Lesson lesson) {
    final notifier = ref.read(completedLessonsProvider.notifier);
    final currentSet = ref.read(completedLessonsProvider);

    if (currentSet.contains(lesson.id)) {
      notifier.state = Set.from(currentSet)..remove(lesson.id);
    } else {
      notifier.state = Set.from(currentSet)..add(lesson.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(videoPlayerNotifierProvider);
    final playerNotifier = ref.read(videoPlayerNotifierProvider.notifier);
    final completedSet = ref.watch(completedLessonsProvider);

    final currentLesson = playerState.currentLesson ?? widget.initialLesson;
    final isCompleted = completedSet.contains(currentLesson.id);

    final currentIndex = widget.playlist.indexWhere((l) => l.id == currentLesson.id);
    final hasNextLesson = currentIndex >= 0 && currentIndex < widget.playlist.length - 1;
    final hasPrevLesson = currentIndex > 0;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Video Viewport (16:9 Aspect Ratio)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                child: _youtubeController != null
                    ? Stack(
                        children: [
                          Positioned.fill(
                            child: YoutubePlayer(
                              controller: _youtubeController!,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.playlist_play_rounded,
                                  color: Colors.white,
                                ),
                                onPressed: () =>
                                    _openPlaylistBottomSheet(currentLesson.id),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          // Video Native View
                          if (playerState.controller != null &&
                              playerState.controller!.value.isInitialized)
                            Center(
                              child: AspectRatio(
                                aspectRatio:
                                    playerState.controller!.value.aspectRatio,
                                child: VideoPlayer(playerState.controller!),
                              ),
                            ),

                          // Loading State with Clean Skeleton Shimmer
                          if (playerState.isLoading)
                            const Positioned.fill(
                              child: VideoPlayerSkeleton(),
                            ),

                          // Custom Controls Overlay
                          if (!playerState.isLoading)
                            CustomPlayerControls(
                              state: playerState,
                              notifier: playerNotifier,
                              onBack: () => Navigator.pop(context),
                              onOpenPlaylist: () =>
                                  _openPlaylistBottomSheet(currentLesson.id),
                            ),

                          // Persistent Back Button during Loading
                          if (playerState.isLoading)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),

            // Lesson Details & Playlist Below Video
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order badge & Duration
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryButton,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Lesson ${currentIndex >= 0 ? currentIndex + 1 : 1} of ${widget.playlist.length}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSecondaryButton,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: AppTheme.iconInactive,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          Formatters.formatVideoTime(
                              Duration(seconds: currentLesson.durationSeconds)),
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: AppTheme.bodyText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Lesson Title
                    if (playerState.isLoading)
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonLoader(width: double.infinity, height: 18, borderRadius: 4),
                          SizedBox(height: 8),
                          SkeletonLoader(width: 200, height: 18, borderRadius: 4),
                        ],
                      )
                    else
                      Text(
                        currentLesson.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.heading,
                          height: 1.3,
                        ),
                      ),
                    const SizedBox(height: 10),

                    // Lesson Description
                    if (playerState.isLoading)
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonLoader(width: double.infinity, height: 13, borderRadius: 3),
                          SizedBox(height: 6),
                          SkeletonLoader(width: double.infinity, height: 13, borderRadius: 3),
                          SizedBox(height: 6),
                          SkeletonLoader(width: 140, height: 13, borderRadius: 3),
                        ],
                      )
                    else
                      Text(
                        currentLesson.description,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          height: 1.5,
                          color: AppTheme.bodyText,
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Mark as Completed Button
                    InkWell(
                      onTap: () => _toggleMarkLessonCompleted(currentLesson),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppTheme.secondaryButton
                              : AppTheme.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCompleted ? AppTheme.primaryButton : AppTheme.outline,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isCompleted
                                  ? Icons.check_circle_rounded
                                  : Icons.check_circle_outline_rounded,
                              color: isCompleted
                                  ? AppTheme.iconActive
                                  : AppTheme.iconInactive,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isCompleted
                                  ? 'Completed'
                                  : 'Mark as Completed',
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isCompleted
                                  ? AppTheme.primaryButton
                                  : AppTheme.heading,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Next & Previous Navigation Row (Primary & Secondary Buttons)
                    Row(
                      children: [
                        if (hasPrevLesson)
                          Expanded(
                            child: SecondaryButton(
                              height: 40,
                              label: 'Sebelumnya',
                              icon: Icons.skip_previous_rounded,
                              onPressed: () {
                                final prevLesson = widget.playlist[currentIndex - 1];
                                playerNotifier.initializeLesson(prevLesson);
                              },
                            ),
                          ),
                        if (hasPrevLesson && hasNextLesson)
                          const SizedBox(width: 10),
                        if (hasNextLesson)
                          Expanded(
                            child: PrimaryGradientButton(
                              height: 40,
                              label: 'Berikutnya',
                              icon: Icons.skip_next_rounded,
                              onPressed: () {
                                final nextLesson = widget.playlist[currentIndex + 1];
                                playerNotifier.initializeLesson(nextLesson);
                              },
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Syllabus Playlist Quick Access
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lesson Playlist',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              _openPlaylistBottomSheet(currentLesson.id),
                          child: Text(
                            'See All',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Quick list of lessons
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.playlist.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final lesson = widget.playlist[index];
                        final isSelected = lesson.id == currentLesson.id;
                        final isLessonDone = completedSet.contains(lesson.id);

                        return LessonTile(
                          lesson: lesson.copyWith(isCompleted: isLessonDone),
                          index: index,
                          isCurrentPlaying: isSelected,
                          onTap: () {
                            if (!isSelected) {
                              playerNotifier.initializeLesson(lesson);
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
