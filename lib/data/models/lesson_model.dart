import '../../domain/entities/lesson.dart';

class LessonModel {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final int durationSeconds;
  final String videoUrl;
  final int order;
  final bool isPreview;
  final bool isCompleted;

  const LessonModel({
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

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      durationSeconds: json['durationSeconds'] as int,
      videoUrl: json['videoUrl'] as String,
      order: json['order'] as int,
      isPreview: json['isPreview'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'description': description,
      'durationSeconds': durationSeconds,
      'videoUrl': videoUrl,
      'order': order,
      'isPreview': isPreview,
      'isCompleted': isCompleted,
    };
  }

  Lesson toEntity() {
    return Lesson(
      id: id,
      courseId: courseId,
      title: title,
      description: description,
      durationSeconds: durationSeconds,
      videoUrl: videoUrl,
      order: order,
      isPreview: isPreview,
      isCompleted: isCompleted,
    );
  }

  factory LessonModel.fromEntity(Lesson entity) {
    return LessonModel(
      id: entity.id,
      courseId: entity.courseId,
      title: entity.title,
      description: entity.description,
      durationSeconds: entity.durationSeconds,
      videoUrl: entity.videoUrl,
      order: entity.order,
      isPreview: entity.isPreview,
      isCompleted: entity.isCompleted,
    );
  }
}
