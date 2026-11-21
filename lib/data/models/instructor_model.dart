import '../../domain/entities/instructor.dart';

class InstructorModel {
  final String id;
  final String name;
  final String role;
  final String avatarUrl;
  final String bio;

  const InstructorModel({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.bio,
  });

  factory InstructorModel.fromJson(Map<String, dynamic> json) {
    return InstructorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      avatarUrl: json['avatarUrl'] as String,
      bio: json['bio'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'avatarUrl': avatarUrl,
      'bio': bio,
    };
  }

  Instructor toEntity() {
    return Instructor(
      id: id,
      name: name,
      role: role,
      avatarUrl: avatarUrl,
      bio: bio,
    );
  }

  factory InstructorModel.fromEntity(Instructor entity) {
    return InstructorModel(
      id: entity.id,
      name: entity.name,
      role: entity.role,
      avatarUrl: entity.avatarUrl,
      bio: entity.bio,
    );
  }
}
