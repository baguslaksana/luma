import '../../data/datasources/course_remote_datasource.dart';
import '../../data/datasources/postgres_course_datasource.dart';
import '../../data/repositories/course_repository_impl.dart';
import '../../domain/repositories/course_repository.dart';
import '../../domain/usecases/course_usecases.dart';

class ServiceLocator {
  ServiceLocator._();

  static late final CourseRemoteDataSource courseRemoteDataSource;
  static late final CourseRepository courseRepository;
  static late final GetCoursesUseCase getCoursesUseCase;
  static late final GetCourseDetailUseCase getCourseDetailUseCase;
  static late final GetCategoriesUseCase getCategoriesUseCase;
  static late final AddCourseUseCase addCourseUseCase;
  static late final AddLessonUseCase addLessonUseCase;
  static late final DeleteCourseUseCase deleteCourseUseCase;
  static late final DeleteLessonUseCase deleteLessonUseCase;

  static void setup() {
    courseRemoteDataSource = PostgresCourseDataSource();
    courseRepository = CourseRepositoryImpl(courseRemoteDataSource);
    getCoursesUseCase = GetCoursesUseCase(courseRepository);
    getCourseDetailUseCase = GetCourseDetailUseCase(courseRepository);
    getCategoriesUseCase = GetCategoriesUseCase(courseRepository);
    addCourseUseCase = AddCourseUseCase(courseRepository);
    addLessonUseCase = AddLessonUseCase(courseRepository);
    deleteCourseUseCase = DeleteCourseUseCase(courseRepository);
    deleteLessonUseCase = DeleteLessonUseCase(courseRepository);
  }
}
