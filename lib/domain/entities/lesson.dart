class Lesson {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final int durationSeconds;
  final String videoUrl;
  final int order;
  final bool isPreview;
  final bool isCompleted;

  const Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.durationSeconds,
    required this.videoUrl,
    required this.order,
    this.isPreview = false,
    this.isCompleted = false,
  });

  Lesson copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    int? durationSeconds,
    String? videoUrl,
    int? order,
    bool? isPreview,
    bool? isCompleted,
  }) {
    return Lesson(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      videoUrl: videoUrl ?? this.videoUrl,
      order: order ?? this.order,
      isPreview: isPreview ?? this.isPreview,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
