enum UserRole {
  siswa,
  pengajar;

  String get displayName {
    switch (this) {
      case UserRole.siswa:
        return 'Student';
      case UserRole.pengajar:
        return 'Teacher';
    }
  }

  bool get isPengajar => this == UserRole.pengajar;
  bool get isSiswa => this == UserRole.siswa;
  bool get isTeacher => this == UserRole.pengajar;
  bool get isStudent => this == UserRole.siswa;
}

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? avatarUrl;
  final String? bio;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.bio,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: (json['role'] as String) == 'pengajar'
          ? UserRole.pengajar
          : UserRole.siswa,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role == UserRole.pengajar ? 'pengajar' : 'siswa',
      'avatarUrl': avatarUrl,
      'bio': bio,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? avatarUrl,
    String? bio,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
    );
  }
}
