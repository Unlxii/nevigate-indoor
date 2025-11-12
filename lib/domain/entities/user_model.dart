import 'package:equatable/equatable.dart';

enum UserRole {
  admin,
  client,
}

class UserModel extends Equatable {
  final String id; // เปลี่ยนจาก uid เป็น id
  final String email;
  final String? displayName;
  final UserRole role;
  final DateTime? createdAt;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.role = UserRole.client,
    this.createdAt,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['uid'], // รองรับทั้ง id และ uid
      email: json['email'],
      displayName: json['displayName'],
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.client,
      ),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'createdAt': createdAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    UserRole? role,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isAdmin => role == UserRole.admin;

  @override
  List<Object?> get props => [id, email, role, isActive];
}
