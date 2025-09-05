/// Enumeración para roles de usuario
enum UserRole {
  user('user'),
  admin('admin');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    switch (value) {
      case 'admin':
        return UserRole.admin;
      case 'user':
      default:
        return UserRole.user;
    }
  }
}

/// Modelo de datos para el usuario completo
class UserModel {
  final String id;
  final String email;
  final UserRole role;
  final String? firstName;
  final String? lastName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? updatedBy;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.firstName,
    this.lastName,
    required this.createdAt,
    required this.updatedAt,
    this.updatedBy,
  });

  /// Crea una instancia desde JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      role: UserRole.fromString(json['role'] as String),
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      updatedBy: json['updated_by'] as String?,
    );
  }

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role.value,
      'first_name': firstName,
      'last_name': lastName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'updated_by': updatedBy,
    };
  }

  /// Obtiene el nombre completo
  String get fullName {
    final parts =
        [firstName, lastName].where((part) => part != null && part.isNotEmpty);
    return parts.isNotEmpty ? parts.join(' ') : email.split('@').first;
  }

  /// Obtiene el primer nombre
  String get displayName =>
      firstName?.isNotEmpty == true ? firstName! : email.split('@').first;

  /// Verifica si el usuario es admin
  bool get isAdmin => role == UserRole.admin;

  /// Verifica si el usuario es un usuario regular
  bool get isUser => role == UserRole.user;

  /// Crea una copia con campos modificados
  UserModel copyWith({
    String? firstName,
    String? lastName,
    UserRole? role,
  }) {
    return UserModel(
      id: id,
      email: email,
      role: role ?? this.role,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      updatedBy: updatedBy,
    );
  }
}
