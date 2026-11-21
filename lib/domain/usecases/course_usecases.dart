import '../entities/category.dart';
import '../entities/course.dart';
import '../entities/lesson.dart';
import '../repositories/course_repository.dart';

class GetCoursesUseCase {
  final CourseRepository _repository;
  const GetCoursesUseCase(this._repository);

  Future<List<Course>> execute({String? categorySlug, String? searchQuery}) {
    return _repository.getCourses(
      categorySlug: categorySlug,
      searchQuery: searchQuery,
    );
  }
}

class GetCourseDetailUseCase {
  final CourseRepository _repository;
  const GetCourseDetailUseCase(this._repository);

  Future<Course?> execute(String courseId) {
    return _repository.getCourseById(courseId);
  }
}

class GetCategoriesUseCase {
  final CourseRepository _repository;
  const GetCategoriesUseCase(this._repository);

  Future<List<Category>> execute() {
    return _repository.getCategories();
  }
}

class AddCourseUseCase {
  final CourseRepository _repository;
  const AddCourseUseCase(this._repository);

  Future<Course> execute(Course course) {
    return _repository.addCourse(course);
  }
}

class AddLessonUseCase {
  final CourseRepository _repository;
  const AddLessonUseCase(this._repository);

  Future<Course> execute(String courseId, Lesson lesson) {
    return _repository.addLessonToCourse(courseId, lesson);
  }
}

class DeleteCourseUseCase {
  final CourseRepository _repository;
  const DeleteCourseUseCase(this._repository);

  Future<void> execute(String courseId) {
    return _repository.deleteCourse(courseId);
  }
}

class DeleteLessonUseCase {
  final CourseRepository _repository;
  const DeleteLessonUseCase(this._repository);

  Future<void> execute(String courseId, String lessonId) {
    return _repository.deleteLesson(courseId, lessonId);
  }
}

