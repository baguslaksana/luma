import '../../domain/entities/course.dart';
import 'category_model.dart';
import 'instructor_model.dart';
import 'lesson_model.dart';

class CourseModel {
  final String id;
  final String title;
  final CategoryModel category;
  final InstructorModel instructor;
  final String description;
  final String thumbnailUrl;
  final double rating;
  final int totalReviews;
  final int totalDurationSeconds;
  final String level;
  final List<LessonModel> lessons;

  const CourseModel({
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

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    // Dukung format instructor objek maupun string instructorName sesuai PRD 7.1 & 9
    final InstructorModel instructorModel;
    if (json['instructor'] is Map<String, dynamic>) {
      instructorModel =
          InstructorModel.fromJson(json['instructor'] as Map<String, dynamic>);
    } else {
      final name = json['instructorName'] as String? ?? 'Instructor';
      instructorModel = InstructorModel(
        id: 'inst-gen',
        name: name,
        role: 'High School Teacher',
        avatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
        bio: 'Experienced high school subject teacher.',
      );
    }

    final categoryModel = json['category'] is Map<String, dynamic>
        ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
        : const CategoryModel(id: 'cat-gen', name: 'Umum', slug: 'all');

    return CourseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: categoryModel,
      instructor: instructorModel,
      description: json['description'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      totalReviews: json['totalReviews'] as int? ?? 100,
      totalDurationSeconds: json['totalDurationSeconds'] as int? ?? 3600,
      level: json['level'] as String? ?? 'SMA',
      lessons: (json['lessons'] as List<dynamic>? ?? [])
          .map((item) => LessonModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category.toJson(),
      'instructor': instructor.toJson(),
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'rating': rating,
      'totalReviews': totalReviews,
      'totalDurationSeconds': totalDurationSeconds,
      'level': level,
      'lessons': lessons.map((l) => l.toJson()).toList(),
    };
  }

  Course toEntity() {
    return Course(
      id: id,
      title: title,
      category: category.toEntity(),
      instructor: instructor.toEntity(),
      description: description,
      thumbnailUrl: thumbnailUrl,
      rating: rating,
      totalReviews: totalReviews,
      totalDurationSeconds: totalDurationSeconds,
      level: level,
      lessons: lessons.map((l) => l.toEntity()).toList(),
    );
  }
}
