import '../../domain/entities/category.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/course_remote_datasource.dart';
import '../models/course_model.dart';
import '../models/category_model.dart';
import '../models/instructor_model.dart';
import '../models/lesson_model.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource _remoteDataSource;

  const CourseRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Course>> getCourses({
    String? categorySlug,
    String? searchQuery,
  }) async {
    final models = await _remoteDataSource.getCourses(
      categorySlug: categorySlug,
      searchQuery: searchQuery,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Course?> getCourseById(String id) async {
    final model = await _remoteDataSource.getCourseById(id);
    return model?.toEntity();
  }

  @override
  Future<List<Category>> getCategories() async {
    final models = await _remoteDataSource.getCategories();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Course> addCourse(Course course) async {
    final model = CourseModel(
      id: course.id,
      title: course.title,
      category: CategoryModel.fromEntity(course.category),
      instructor: InstructorModel.fromEntity(course.instructor),
      description: course.description,
      thumbnailUrl: course.thumbnailUrl,
      rating: course.rating,
      totalReviews: course.totalReviews,
      totalDurationSeconds: course.totalDurationSeconds,
      level: course.level,
      lessons: course.lessons.map((l) => LessonModel.fromEntity(l)).toList(),
    );
    final result = await _remoteDataSource.addCourse(model);
    return result.toEntity();
  }

  @override
  Future<Course> addLessonToCourse(String courseId, Lesson lesson) async {
    final lessonModel = LessonModel.fromEntity(lesson);
    final result = await _remoteDataSource.addLessonToCourse(courseId, lessonModel);
    return result.toEntity();
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    await _remoteDataSource.deleteCourse(courseId);
  }

  @override
  Future<void> deleteLesson(String courseId, String lessonId) async {
    await _remoteDataSource.deleteLesson(courseId, lessonId);
  }
}
