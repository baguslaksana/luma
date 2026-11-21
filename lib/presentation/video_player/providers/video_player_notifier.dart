import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../domain/entities/lesson.dart';
import 'video_player_state.dart';

class VideoPlayerNotifier extends StateNotifier<VideoPlayerState> {
  Timer? _hideControlsTimer;

  VideoPlayerNotifier() : super(const VideoPlayerState());

  Future<void> initializeLesson(Lesson lesson) async {
    // 1. Matikan dan bersihkan controller lama jika ada untuk mencegah memory leak
    await _disposeCurrentController();

    state = state.copyWith(
      currentLesson: lesson,
      status: VideoPlaybackStatus.loading,
      position: Duration.zero,
      duration: Duration.zero,
      buffered: Duration.zero,
      errorMessage: null,
      areControlsVisible: true,
    );

    // Validasi URL video kosong sesuai PRD FR-03 & Error Handling Requirements
    if (lesson.videoUrl.trim().isEmpty) {
      state = state.copyWith(
        status: VideoPlaybackStatus.error,
        errorMessage: 'Lesson video is not yet available for this lesson.',
      );
      return;
    }

    // Check if video is a YouTube URL
    final ytId = YoutubePlayerController.convertUrlToId(lesson.videoUrl.trim());
    if (ytId != null) {
      state = state.copyWith(
        status: VideoPlaybackStatus.playing,
        controller: null,
        errorMessage: null,
      );
      return;
    }

    try {
      VideoPlayerController controller;
      final trimmedUrl = lesson.videoUrl.trim();
      if (trimmedUrl.startsWith('assets/')) {
        controller = VideoPlayerController.asset(trimmedUrl);
      } else if (trimmedUrl.startsWith('http')) {
        controller = VideoPlayerController.networkUrl(Uri.parse(trimmedUrl));
      } else {
        controller = VideoPlayerController.asset('assets/videos/sample_lesson.mp4');
      }

      try {
        await controller.initialize();
      } catch (_) {
        controller = VideoPlayerController.asset('assets/videos/sample_lesson.mp4');
        await controller.initialize();
      }

      controller.setPlaybackSpeed(state.playbackSpeed);

      // Listener sinkronisasi waktu dan status
      controller.addListener(() {
        if (!mounted) return;
        final value = controller.value;
        if (value.hasError) {
          _fallbackToAssetVideo();
          return;
        }

        final isFinished = value.position >= value.duration && value.duration > Duration.zero;

        state = state.copyWith(
          position: value.position,
          duration: value.duration,
          buffered: value.buffered.isNotEmpty ? value.buffered.last.end : Duration.zero,
          status: isFinished
              ? VideoPlaybackStatus.completed
              : (value.isPlaying ? VideoPlaybackStatus.playing : VideoPlaybackStatus.paused),
        );
      });

      await controller.play();

      state = state.copyWith(
        controller: controller,
        status: VideoPlaybackStatus.playing,
        duration: controller.value.duration,
      );

      _startHideControlsTimer();
    } catch (_) {
      await _fallbackToAssetVideo();
    }
  }

  Future<void> _fallbackToAssetVideo() async {
    try {
      await _disposeCurrentController();
      final controller = VideoPlayerController.asset('assets/videos/sample_lesson.mp4');
      await controller.initialize();
      controller.setPlaybackSpeed(state.playbackSpeed);

      controller.addListener(() {
        if (!mounted) return;
        final val = controller.value;
        final isFinished = val.position >= val.duration && val.duration > Duration.zero;
        state = state.copyWith(
          position: val.position,
          duration: val.duration,
          buffered: val.buffered.isNotEmpty ? val.buffered.last.end : Duration.zero,
          status: isFinished
              ? VideoPlaybackStatus.completed
              : (val.isPlaying ? VideoPlaybackStatus.playing : VideoPlaybackStatus.paused),
        );
      });

      await controller.play();
      state = state.copyWith(
        controller: controller,
        status: VideoPlaybackStatus.playing,
        duration: controller.value.duration,
        errorMessage: null,
      );
      _startHideControlsTimer();
    } catch (_) {}
  }

  void pause() {
    final controller = state.controller;
    if (controller != null && controller.value.isInitialized && controller.value.isPlaying) {
      controller.pause();
      _cancelHideControlsTimer();
      state = state.copyWith(areControlsVisible: true);
    }
  }

  void togglePlayPause() {
    final controller = state.controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      controller.pause();
      _cancelHideControlsTimer();
      state = state.copyWith(areControlsVisible: true);
    } else {
      controller.play();
      _startHideControlsTimer();
    }
  }

  Future<void> seekTo(Duration position) async {
    final controller = state.controller;
    if (controller == null || !controller.value.isInitialized) return;

    await controller.seekTo(position);
    _startHideControlsTimer();
  }

  Future<void> seekRelative(int seconds) async {
    final controller = state.controller;
    if (controller == null || !controller.value.isInitialized) return;

    final newPos = controller.value.position + Duration(seconds: seconds);
    final clampedPos = newPos < Duration.zero
        ? Duration.zero
        : (newPos > controller.value.duration ? controller.value.duration : newPos);

    await controller.seekTo(clampedPos);
    _startHideControlsTimer();
  }

  Future<void> setPlaybackSpeed(double speed) async {
    final controller = state.controller;
    if (controller != null && controller.value.isInitialized) {
      await controller.setPlaybackSpeed(speed);
    }
    state = state.copyWith(playbackSpeed: speed);
  }

  void toggleControlsVisibility() {
    if (state.areControlsVisible) {
      _cancelHideControlsTimer();
      state = state.copyWith(areControlsVisible: false);
    } else {
      state = state.copyWith(areControlsVisible: true);
      if (state.isPlaying) {
        _startHideControlsTimer();
      }
    }
  }

  void _startHideControlsTimer() {
    _cancelHideControlsTimer();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && state.isPlaying) {
        state = state.copyWith(areControlsVisible: false);
      }
    });
  }

  void _cancelHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = null;
  }

  Future<void> _disposeCurrentController() async {
    _cancelHideControlsTimer();
    final controller = state.controller;
    if (controller != null) {
      try {
        await controller.pause();
      } catch (_) {}
      controller.dispose();
      state = state.copyWith(controller: null);
    }
  }

  @override
  void dispose() {
    _disposeCurrentController();
    super.dispose();
  }
}

final videoPlayerNotifierProvider =
    StateNotifierProvider.autoDispose<VideoPlayerNotifier, VideoPlayerState>((ref) {
  return VideoPlayerNotifier();
});
