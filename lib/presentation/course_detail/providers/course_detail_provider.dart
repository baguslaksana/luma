import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/entities/course.dart';

// State Provider untuk mencatat ID lesson yang sudah ditandai selesai (reactive progress)
final completedLessonsProvider = StateProvider<Set<String>>((ref) {
  // Initial default: pelajaran pengantar awal sudah tuntas
  return {'ls-mat-01', 'ls-fis-01'};
});

// FutureProviderFamily untuk mengambil detail course berdasarkan ID
final courseDetailProvider =
    FutureProvider.family<Course?, String>((ref, courseId) async {
  final course = await ServiceLocator.getCourseDetailUseCase.execute(courseId);
  if (course == null) return null;

  final completedSet = ref.watch(completedLessonsProvider);

  // Update status isCompleted dari state lokal
  final updatedLessons = course.lessons.map((lesson) {
    return lesson.copyWith(isCompleted: completedSet.contains(lesson.id));
  }).toList();

  return Course(
    id: course.id,
    title: course.title,
    category: course.category,
    instructor: course.instructor,
    description: course.description,
    thumbnailUrl: course.thumbnailUrl,
    rating: course.rating,
    totalReviews: course.totalReviews,
    totalDurationSeconds: course.totalDurationSeconds,
    level: course.level,
    lessons: updatedLessons,
  );
});
