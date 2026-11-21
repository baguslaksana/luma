import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma/core/di/service_locator.dart';
import 'package:luma/data/datasources/mock_course_datasource.dart';
import 'package:luma/data/repositories/course_repository_impl.dart';
import 'package:luma/domain/usecases/course_usecases.dart';
import 'package:luma/data/models/category_model.dart';
import 'package:luma/data/models/course_model.dart';
import 'package:luma/data/models/instructor_model.dart';
import 'package:luma/data/models/lesson_model.dart';
import 'package:luma/main.dart';
import 'package:luma/presentation/auth/views/login_screen.dart';
import 'package:luma/presentation/auth/views/signup_screen.dart';
import 'package:luma/presentation/course_detail/views/course_detail_screen.dart';
import 'package:luma/presentation/home/views/home_screen.dart';
import 'package:luma/presentation/onboarding/views/onboarding_screen.dart';
import 'package:luma/presentation/auth/providers/auth_provider.dart';

void main() {
  setUp(() {
    MockCourseDataSource.resetToEmpty();
    ServiceLocator.courseRemoteDataSource = MockCourseDataSource();
    ServiceLocator.courseRepository = CourseRepositoryImpl(ServiceLocator.courseRemoteDataSource);
    ServiceLocator.getCoursesUseCase = GetCoursesUseCase(ServiceLocator.courseRepository);
    ServiceLocator.getCourseDetailUseCase = GetCourseDetailUseCase(ServiceLocator.courseRepository);
    ServiceLocator.getCategoriesUseCase = GetCategoriesUseCase(ServiceLocator.courseRepository);
    ServiceLocator.addCourseUseCase = AddCourseUseCase(ServiceLocator.courseRepository);
    ServiceLocator.addLessonUseCase = AddLessonUseCase(ServiceLocator.courseRepository);
    ServiceLocator.deleteCourseUseCase = DeleteCourseUseCase(ServiceLocator.courseRepository);
    ServiceLocator.deleteLessonUseCase = DeleteLessonUseCase(ServiceLocator.courseRepository);
  });

  const sampleCourse = CourseModel(
    id: 'course-matematika-sma',
    title: 'High School Calculus & Trigonometry',
    category: CategoryModel(id: 'cat-matematika', name: 'Mathematics', slug: 'matematika'),
    instructor: InstructorModel(
      id: 'inst-bambang',
      name: 'Drs. Bambang Sudarsono, M.Pd.',
      role: 'Senior High School Mathematics Teacher',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
      bio: 'Senior mathematics teacher.',
    ),
    description: 'Master limits, derivatives, algebraic integrals, and trigonometric equations.',
    thumbnailUrl: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&w=800&q=80',
    rating: 4.9,
    totalReviews: 1420,
    totalDurationSeconds: 30600,
    level: 'Grades 11 - 12',
    lessons: [
      LessonModel(
        id: 'ls-mat-01',
        courseId: 'course-matematika-sma',
        title: 'Limits of Algebraic Functions & Infinity',
        description: 'Understand limits of algebraic functions.',
        durationSeconds: 632,
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        order: 1,
        isPreview: true,
        isCompleted: true,
      ),
    ],
  );

  testWidgets('LumaApp initializes and shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LumaApp(),
      ),
    );

    // Verify Splash screen shows luma brand logo
    expect(find.text('luma'), findsOneWidget);
  });

  testWidgets('OnboardingScreen renders header, slider content, and buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );

    // Verify logo, slide title, and action buttons
    expect(find.text('luma'), findsOneWidget);
    expect(find.text('Welcome to Luma!'), findsOneWidget);
    expect(find.text('Access Your Account'), findsOneWidget);
    expect(find.textContaining("Don't have an account?"), findsOneWidget);
    expect(find.text('Signup'), findsOneWidget);
  });

  testWidgets('SignUpScreen renders Create Account form with role selector', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SignUpScreen(),
        ),
      ),
    );

    expect(find.text('Create\nAccount'), findsOneWidget);
    expect(find.text('Register As'), findsOneWidget);
    expect(find.text('Student'), findsOneWidget);
    expect(find.text('Teacher'), findsOneWidget);
    expect(find.text('Your Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Sign up with Google'), findsOneWidget);
  });

  testWidgets('LoginScreen renders Welcome Back form with demo buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    expect(find.text('Welcome\nBack'), findsOneWidget);
    expect(find.text('Demo Accounts'), findsOneWidget);
    expect(find.text('Student'), findsWidgets);
    expect(find.text('Teacher'), findsWidgets);
    expect(find.text('Your Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
  });

  testWidgets('HomeScreen renders welcome header for student role and empty state when no courses', (WidgetTester tester) async {
    // Provide overrides to simulate logged-in Student user
    final container = ProviderContainer(
      overrides: [
        authNotifierProvider.overrideWith((ref) {
          final ds = ref.watch(authDataSourceProvider);
          final notifier = AuthNotifier(ds);
          return notifier;
        }),
      ],
    );

    // Simulate login
    await container.read(authNotifierProvider.notifier).login(
          email: 'siswa@luma.com',
          password: 'siswa',
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('ARI BAGUS'), findsOneWidget);
    expect(find.text('Student'), findsOneWidget);
    expect(find.text('Featured Courses'), findsOneWidget);
    expect(find.text('No courses available yet.'), findsOneWidget);
  });

  testWidgets('CourseDetailScreen renders course info, instructor, and lessons', (WidgetTester tester) async {
    MockCourseDataSource.seedCourse(sampleCourse);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CourseDetailScreen(courseId: 'course-matematika-sma'),
        ),
      ),
    );

    // Initial pump and wait for mock data to resolve
    await tester.pumpAndSettle();

    expect(find.text('High School Calculus & Trigonometry'), findsOneWidget);
    expect(find.text('Instructor'), findsOneWidget);
    expect(find.text('Course Description'), findsOneWidget);
    expect(find.text('Curriculum'), findsOneWidget);
  });

  testWidgets('Teacher can view Add Lesson button in CourseDetailScreen', (WidgetTester tester) async {
    MockCourseDataSource.seedCourse(sampleCourse);

    final container = ProviderContainer(
      overrides: [
        authNotifierProvider.overrideWith((ref) {
          final ds = ref.watch(authDataSourceProvider);
          return AuthNotifier(ds);
        }),
      ],
    );

    // Login as Teacher
    await container.read(authNotifierProvider.notifier).login(
          email: 'pengajar@luma.com',
          password: 'pengajar',
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: CourseDetailScreen(courseId: 'course-matematika-sma'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify teacher sees "Add Lesson" button
    expect(find.text('Add Lesson'), findsOneWidget);
  });
}
