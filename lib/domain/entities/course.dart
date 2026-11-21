import 'category.dart';
import 'instructor.dart';
import 'lesson.dart';

class Course {
  final String id;
  final String title;
  final Category category;
  final Instructor instructor;
  final String description;
  final String thumbnailUrl;
  final double rating;
  final int totalReviews;
  final int totalDurationSeconds;
  final String level;
  final List<Lesson> lessons;

  const Course({
    required this.id,
    required this.title,
    required this.category,
    required this.instructor,
    required this.description,
    required this.thumbnailUrl,
    required this.rating,
    required this.totalReviews,
    required this.totalDurationSeconds,
    required this.level,
    required this.lessons,
  });

  int get totalLessons => lessons.length;

  String get instructorName => instructor.name;

  int get completedLessonsCount => lessons.where((l) => l.isCompleted).length;

  double get progressPercentage =>
      lessons.isEmpty ? 0.0 : completedLessonsCount / lessons.length;
}
