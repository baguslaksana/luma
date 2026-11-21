import 'dart:developer' as developer;
import 'package:postgres/postgres.dart';
import '../models/category_model.dart';
import '../models/course_model.dart';
import '../models/instructor_model.dart';
import '../models/lesson_model.dart';
import 'course_remote_datasource.dart';
import 'dummy_course_seed.dart';
import 'postgres_connection_helper.dart';

class PostgresCourseDataSource implements CourseRemoteDataSource {
  // In-memory fallback cache when PostgreSQL is offline or unreachable
  static final List<CourseModel> _fallbackCourses = List.from(DummyCourseSeed.initialCourses);
  static final List<CategoryModel> _fallbackCategories = [
    const CategoryModel(id: 'cat-matematika', name: 'Matematika', slug: 'matematika'),
    const CategoryModel(id: 'cat-fisika', name: 'Fisika', slug: 'fisika'),
    const CategoryModel(id: 'cat-biologi', name: 'Biologi', slug: 'biologi'),
    const CategoryModel(id: 'cat-kimia', name: 'Kimia', slug: 'kimia'),
    const CategoryModel(id: 'cat-bahasa', name: 'Bahasa & Literasi', slug: 'bahasa'),
    const CategoryModel(id: 'cat-utbk', name: 'Persiapan UTBK', slug: 'utbk'),
  ];

  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  @override
  Future<List<CourseModel>> getCourses({
    String? categorySlug,
    String? searchQuery,
  }) async {
    Connection? conn;
    try {
      conn = await PostgresConnectionHelper.openConnection();
      if (conn != null) {
        // Query courses with joined categories and instructors
        final coursesResult = await conn.execute(
          Sql.named('''
            SELECT 
              c.id, c.title, c.description, c.thumbnail_url, c.level, c.total_duration_seconds,
              cat.id AS cat_id, cat.name AS cat_name, cat.slug AS cat_slug,
              u.id AS user_id, u.full_name, u.role, u.avatar_url, u.bio
            FROM courses c
            LEFT JOIN categories cat ON c.category_id = cat.id
            LEFT JOIN users u ON c.instructor_id = u.id
            ORDER BY c.created_at DESC
          '''),
        );

        // Query lessons for all courses
        final lessonsResult = await conn.execute(
          Sql.named('''
            SELECT 
              id, course_id, title, description, duration_seconds, video_url, order_index, is_preview
            FROM lessons
            ORDER BY order_index ASC
          '''),
        );

        // Group lessons by course_id
        final Map<String, List<LessonModel>> lessonsByCourse = {};
        for (final row in lessonsResult) {
          final courseId = row[1] as String;
          final lesson = LessonModel(
            id: row[0] as String,
            courseId: courseId,
            title: row[2] as String,
            description: (row[3] as String?) ?? '',
            durationSeconds: (row[4] as int?) ?? 0,
            videoUrl: row[5] as String,
            order: (row[6] as int?) ?? 1,
            isPreview: (row[7] as bool?) ?? false,
          );
          lessonsByCourse.putIfAbsent(courseId, () => []).add(lesson);
        }

        final List<CourseModel> loadedCourses = [];
        for (final row in coursesResult) {
          final courseId = row[0] as String;
          final catId = row[6] as String? ?? 'cat-gen';
          final catName = row[7] as String? ?? 'General';
          final catSlug = row[8] as String? ?? 'general';

          final instId = row[9]?.toString() ?? 'inst-gen';
          final instName = row[10] as String? ?? 'Teacher';
          final instBio = row[13] as String? ?? '';
          final instAvatar = row[12] as String? ??
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80';

          loadedCourses.add(
            CourseModel(
              id: courseId,
              title: row[1] as String,
              description: (row[2] as String?) ?? '',
              thumbnailUrl: (row[3] as String?) ?? '',
              level: (row[4] as String?) ?? 'All Levels',
              totalDurationSeconds: (row[5] as int?) ?? 0,
              rating: 4.8,
              totalReviews: 120,
              category: CategoryModel(id: catId, name: catName, slug: catSlug),
              instructor: InstructorModel(
                id: instId,
                name: instName,
                role: 'High School Teacher',
                avatarUrl: instAvatar,
                bio: instBio,
              ),
              lessons: lessonsByCourse[courseId] ?? [],
            ),
          );
        }

        // If DB has courses, sync local cache. If DB is empty, seed it with initial dummy courses!
        if (loadedCourses.isNotEmpty) {
          _fallbackCourses.clear();
          _fallbackCourses.addAll(loadedCourses);
        } else if (_fallbackCourses.isNotEmpty) {
          for (final course in List<CourseModel>.from(_fallbackCourses)) {
            await addCourse(course);
          }
        }
      }
    } catch (e, st) {
      developer.log('[PostgreSQL] getCourses fallback to cache: $e', stackTrace: st);
    } finally {
      await conn?.close();
    }

    // Apply filtering on result
    List<CourseModel> results = List.from(_fallbackCourses);
    if (categorySlug != null && categorySlug.isNotEmpty && categorySlug != 'all') {
      results = results.where((c) => c.category.slug == categorySlug).toList();
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      results = results.where((c) =>
        c.title.toLowerCase().contains(q) ||
        c.description.toLowerCase().contains(q) ||
        c.category.name.toLowerCase().contains(q),
      ).toList();
    }
    return results;
  }

  @override
  Future<CourseModel?> getCourseById(String id) async {
    final list = await getCourses();
    try {
      return list.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    Connection? conn;
    try {
      conn = await PostgresConnectionHelper.openConnection();
      if (conn != null) {
        final result = await conn.execute(
          Sql.named('SELECT id, name, slug FROM categories ORDER BY name ASC'),
        );
        final categories = result.map((r) => CategoryModel(
          id: r[0] as String,
          name: r[1] as String,
          slug: r[2] as String,
        )).toList();

        if (categories.isNotEmpty) {
          _fallbackCategories.clear();
          _fallbackCategories.addAll(categories);
        }
      }
    } catch (e) {
      developer.log('[PostgreSQL] getCategories fallback: $e');
    } finally {
      await conn?.close();
    }
    return List.from(_fallbackCategories);
  }

  @override
  Future<CourseModel> addCourse(CourseModel course) async {
    // 1. Update in-memory fallback cache immediately
    final existingIndex = _fallbackCourses.indexWhere((c) => c.id == course.id);
    if (existingIndex >= 0) {
      _fallbackCourses[existingIndex] = course;
    } else {
      _fallbackCourses.insert(0, course);
    }

    // 2. Persist to PostgreSQL database
    Connection? conn;
    try {
      conn = await PostgresConnectionHelper.openConnection();
      if (conn != null) {
        // Ensure category exists
        await conn.execute(
          Sql.named('''
            INSERT INTO categories (id, name, slug)
            VALUES (@id, @name, @slug)
            ON CONFLICT (id) DO NOTHING
          '''),
          parameters: {
            'id': course.category.id,
            'name': course.category.name,
            'slug': course.category.slug,
          },
        );

        // Sanitize instructor UUID
        String instructorId = course.instructor.id;
        if (!_uuidRegex.hasMatch(instructorId)) {
          instructorId = 'a1111111-1111-1111-1111-111111111111';
        }

        // Insert or update course
        await conn.execute(
          Sql.named('''
            INSERT INTO courses (
              id, title, category_id, instructor_id, description,
              thumbnail_url, level, total_duration_seconds, created_at, updated_at
            )
            VALUES (
              @id, @title, @categoryId, @instructorId::uuid, @description,
              @thumbnailUrl, @level, @totalDurationSeconds, NOW(), NOW()
            )
            ON CONFLICT (id) DO UPDATE SET
              title = EXCLUDED.title,
              category_id = EXCLUDED.category_id,
              description = EXCLUDED.description,
              thumbnail_url = EXCLUDED.thumbnail_url,
              level = EXCLUDED.level,
              total_duration_seconds = EXCLUDED.total_duration_seconds,
              updated_at = NOW()
          '''),
          parameters: {
            'id': course.id,
            'title': course.title,
            'categoryId': course.category.id,
            'instructorId': instructorId,
            'description': course.description,
            'thumbnailUrl': course.thumbnailUrl,
            'level': course.level,
            'totalDurationSeconds': course.totalDurationSeconds,
          },
        );

        // Insert or update lessons
        for (final lesson in course.lessons) {
          await conn.execute(
            Sql.named('''
              INSERT INTO lessons (
                id, course_id, title, description, duration_seconds,
                video_url, order_index, is_preview
              )
              VALUES (
                @id, @courseId, @title, @description, @durationSeconds,
                @videoUrl, @orderIndex, @isPreview
              )
              ON CONFLICT (id) DO UPDATE SET
                title = EXCLUDED.title,
                description = EXCLUDED.description,
                duration_seconds = EXCLUDED.duration_seconds,
                video_url = EXCLUDED.video_url,
                order_index = EXCLUDED.order_index,
                is_preview = EXCLUDED.is_preview
            '''),
            parameters: {
              'id': lesson.id,
              'courseId': course.id,
              'title': lesson.title,
              'description': lesson.description,
              'durationSeconds': lesson.durationSeconds,
              'videoUrl': lesson.videoUrl,
              'orderIndex': lesson.order,
              'isPreview': lesson.isPreview,
            },
          );
        }
        developer.log('[PostgreSQL] Successfully saved course "${course.title}" to database.');
      }
    } catch (e, st) {
      developer.log('[PostgreSQL] addCourse error: $e', stackTrace: st);
    } finally {
      await conn?.close();
    }

    return course;
  }

  @override
  Future<CourseModel> addLessonToCourse(String courseId, LessonModel lesson) async {
    // 1. Update in-memory fallback
    CourseModel? targetCourse;
    final index = _fallbackCourses.indexWhere((c) => c.id == courseId);
    if (index >= 0) {
      final current = _fallbackCourses[index];
      final updatedLessons = List<LessonModel>.from(current.lessons)..add(lesson);
      final newTotalDuration = updatedLessons.fold<int>(0, (sum, l) => sum + l.durationSeconds);
      targetCourse = CourseModel(
        id: current.id,
        title: current.title,
        category: current.category,
        instructor: current.instructor,
        description: current.description,
        thumbnailUrl: current.thumbnailUrl,
        rating: current.rating,
        totalReviews: current.totalReviews,
        totalDurationSeconds: newTotalDuration,
        level: current.level,
        lessons: updatedLessons,
      );
      _fallbackCourses[index] = targetCourse;
    }

    // 2. Persist to PostgreSQL
    Connection? conn;
    try {
      conn = await PostgresConnectionHelper.openConnection();
      if (conn != null) {
        await conn.execute(
          Sql.named('''
            INSERT INTO lessons (
              id, course_id, title, description, duration_seconds,
              video_url, order_index, is_preview
            )
            VALUES (
              @id, @courseId, @title, @description, @durationSeconds,
              @videoUrl, @orderIndex, @isPreview
            )
            ON CONFLICT (id) DO UPDATE SET
              title = EXCLUDED.title,
              description = EXCLUDED.description,
              duration_seconds = EXCLUDED.duration_seconds,
              video_url = EXCLUDED.video_url,
              order_index = EXCLUDED.order_index,
              is_preview = EXCLUDED.is_preview
          '''),
          parameters: {
            'id': lesson.id,
            'courseId': courseId,
            'title': lesson.title,
            'description': lesson.description,
            'durationSeconds': lesson.durationSeconds,
            'videoUrl': lesson.videoUrl,
            'orderIndex': lesson.order,
            'isPreview': lesson.isPreview,
          },
        );

        // Recalculate duration in PostgreSQL
        await conn.execute(
          Sql.named('''
            UPDATE courses
            SET total_duration_seconds = (
              SELECT COALESCE(SUM(duration_seconds), 0)
              FROM lessons
              WHERE course_id = @courseId
            ),
            updated_at = NOW()
            WHERE id = @courseId
          '''),
          parameters: {'courseId': courseId},
        );
        developer.log('[PostgreSQL] Successfully added lesson "${lesson.title}" to course $courseId.');
      }
    } catch (e, st) {
      developer.log('[PostgreSQL] addLesson error: $e', stackTrace: st);
    } finally {
      await conn?.close();
    }

    return targetCourse ??
        (await getCourseById(courseId)) ??
        CourseModel(
          id: courseId,
          title: 'Course',
          category: const CategoryModel(id: 'cat-gen', name: 'General', slug: 'general'),
          instructor: const InstructorModel(
            id: 'inst-gen',
            name: 'Teacher',
            role: 'Teacher',
            avatarUrl: '',
            bio: '',
          ),
          description: '',
          thumbnailUrl: '',
          rating: 4.8,
          totalReviews: 100,
          totalDurationSeconds: lesson.durationSeconds,
          level: 'SMA',
          lessons: [lesson],
        );
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    _fallbackCourses.removeWhere((c) => c.id == courseId);

    Connection? conn;
    try {
      conn = await PostgresConnectionHelper.openConnection();
      if (conn != null) {
        await conn.execute(
          Sql.named('DELETE FROM courses WHERE id = @id'),
          parameters: {'id': courseId},
        );
      }
    } catch (e) {
      developer.log('[PostgreSQL] deleteCourse error: $e');
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<void> deleteLesson(String courseId, String lessonId) async {
    final index = _fallbackCourses.indexWhere((c) => c.id == courseId);
    if (index >= 0) {
      final current = _fallbackCourses[index];
      final updatedLessons = current.lessons.where((l) => l.id != lessonId).toList();
      _fallbackCourses[index] = CourseModel(
        id: current.id,
        title: current.title,
        category: current.category,
        instructor: current.instructor,
        description: current.description,
        thumbnailUrl: current.thumbnailUrl,
        rating: current.rating,
        totalReviews: current.totalReviews,
        totalDurationSeconds: updatedLessons.fold(0, (sum, l) => sum + l.durationSeconds),
        level: current.level,
        lessons: updatedLessons,
      );
    }

    Connection? conn;
    try {
      conn = await PostgresConnectionHelper.openConnection();
      if (conn != null) {
        await conn.execute(
          Sql.named('DELETE FROM lessons WHERE id = @id AND course_id = @courseId'),
          parameters: {'id': lessonId, 'courseId': courseId},
        );
      }
    } catch (e) {
      developer.log('[PostgreSQL] deleteLesson error: $e');
    } finally {
      await conn?.close();
    }
  }
}
