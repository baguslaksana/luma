import '../models/category_model.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart';
import 'course_remote_datasource.dart';
import 'dummy_course_seed.dart';

class MockCourseDataSource implements CourseRemoteDataSource {
  static const List<CategoryModel> _categories = [
    CategoryModel(id: 'cat-semua', name: 'All', slug: 'all'),
    CategoryModel(id: 'cat-matematika', name: 'Mathematics', slug: 'matematika'),
    CategoryModel(id: 'cat-fisika', name: 'Physics', slug: 'fisika'),
    CategoryModel(id: 'cat-kimia', name: 'Chemistry', slug: 'kimia'),
    CategoryModel(id: 'cat-biologi', name: 'Biology', slug: 'biologi'),
    CategoryModel(id: 'cat-bahasa', name: 'Language & Literacy', slug: 'bahasa'),
    CategoryModel(id: 'cat-utbk', name: 'College Prep', slug: 'utbk'),
  ];

  static final List<CourseModel> _courses = List.from(DummyCourseSeed.initialCourses);

  static void resetToEmpty() {
    _courses.clear();
  }

  static void seedCourse(CourseModel course) {
    _courses.add(course);
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _categories;
  }

  @override
  Future<List<CourseModel>> getCourses({
    String? categorySlug,
    String? searchQuery,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));

    var results = List<CourseModel>.from(_courses);

    if (categorySlug != null &&
        categorySlug.isNotEmpty &&
        categorySlug != 'all') {
      results = results
          .where((course) => course.category.slug == categorySlug)
          .toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.toLowerCase().trim();
      results = results.where((course) {
        final titleMatch = course.title.toLowerCase().contains(query);
        final descMatch = course.description.toLowerCase().contains(query);
        final instructorMatch =
            course.instructor.name.toLowerCase().contains(query);
        final categoryMatch =
            course.category.name.toLowerCase().contains(query);
        return titleMatch || descMatch || instructorMatch || categoryMatch;
      }).toList();
    }

    return results;
  }

  @override
  Future<CourseModel?> getCourseById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _courses.firstWhere((course) => course.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<CourseModel> addCourse(CourseModel course) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _courses.insert(0, course);
    return course;
  }

  @override
  Future<CourseModel> addLessonToCourse(String courseId, LessonModel lesson) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _courses.indexWhere((c) => c.id == courseId);
    if (index == -1) throw Exception('Course not found.');

    final existing = _courses[index];
    final updatedLessons = [...existing.lessons, lesson];
    final totalDuration =
        updatedLessons.fold<int>(0, (sum, l) => sum + l.durationSeconds);

    final updated = CourseModel(
      id: existing.id,
      title: existing.title,
      category: existing.category,
      instructor: existing.instructor,
      description: existing.description,
      thumbnailUrl: existing.thumbnailUrl,
      rating: existing.rating,
      totalReviews: existing.totalReviews,
      totalDurationSeconds: totalDuration,
      level: existing.level,
      lessons: updatedLessons,
    );
    _courses[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _courses.removeWhere((c) => c.id == courseId);
  }

  @override
  Future<void> deleteLesson(String courseId, String lessonId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _courses.indexWhere((c) => c.id == courseId);
    if (index == -1) return;

    final existing = _courses[index];
    final updatedLessons =
        existing.lessons.where((l) => l.id != lessonId).toList();
    final totalDuration =
        updatedLessons.fold<int>(0, (sum, l) => sum + l.durationSeconds);

    _courses[index] = CourseModel(
      id: existing.id,
      title: existing.title,
      category: existing.category,
      instructor: existing.instructor,
      description: existing.description,
      thumbnailUrl: existing.thumbnailUrl,
      rating: existing.rating,
      totalReviews: existing.totalReviews,
      totalDurationSeconds: totalDuration,
      level: existing.level,
      lessons: updatedLessons,
    );
  }
}
