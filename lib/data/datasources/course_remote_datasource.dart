import '../models/category_model.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart';

abstract class CourseRemoteDataSource {
  Future<List<CourseModel>> getCourses({String? categorySlug, String? searchQuery});
  Future<CourseModel?> getCourseById(String id);
  Future<List<CategoryModel>> getCategories();
  Future<CourseModel> addCourse(CourseModel course);
  Future<CourseModel> addLessonToCourse(String courseId, LessonModel lesson);
  Future<void> deleteCourse(String courseId);
  Future<void> deleteLesson(String courseId, String lessonId);
}
