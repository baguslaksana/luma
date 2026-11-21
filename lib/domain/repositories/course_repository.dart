import '../entities/category.dart';
import '../entities/course.dart';
import '../entities/lesson.dart';

abstract class CourseRepository {
  Future<List<Course>> getCourses({String? categorySlug, String? searchQuery});
  Future<Course?> getCourseById(String id);
  Future<List<Category>> getCategories();
  Future<Course> addCourse(Course course);
  Future<Course> addLessonToCourse(String courseId, Lesson lesson);
  Future<void> deleteCourse(String courseId);
  Future<void> deleteLesson(String courseId, String lessonId);
}
