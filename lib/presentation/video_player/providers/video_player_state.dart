import 'package:video_player/video_player.dart';
import '../../../domain/entities/lesson.dart';

enum VideoPlaybackStatus { initial, loading, playing, paused, completed, error }

class VideoPlayerState {
  final Lesson? currentLesson;
  final VideoPlaybackStatus status;
  final Duration position;
  final Duration duration;
  final Duration buffered;
  final double playbackSpeed;
  final String? errorMessage;
  final bool areControlsVisible;
  final VideoPlayerController? controller;

  const VideoPlayerState({
    this.currentLesson,
    this.status = VideoPlaybackStatus.initial,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.buffered = Duration.zero,
    this.playbackSpeed = 1.0,
    this.errorMessage,
    this.areControlsVisible = true,
    this.controller,
  });

  bool get isLoading => status == VideoPlaybackStatus.loading;
  bool get isPlaying => status == VideoPlaybackStatus.playing;
  bool get isPaused => status == VideoPlaybackStatus.paused;
  bool get isError => status == VideoPlaybackStatus.error;

  VideoPlayerState copyWith({
    Lesson? currentLesson,
    VideoPlaybackStatus? status,
    Duration? position,
    Duration? duration,
    Duration? buffered,
    double? playbackSpeed,
    String? errorMessage,
    bool? areControlsVisible,
    VideoPlayerController? controller,
  }) {
    return VideoPlayerState(
      currentLesson: currentLesson ?? this.currentLesson,
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      buffered: buffered ?? this.buffered,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      errorMessage: errorMessage ?? this.errorMessage,
      areControlsVisible: areControlsVisible ?? this.areControlsVisible,
      controller: controller ?? this.controller,
    );
  }
}
