class User {
  final String id;
  final String name;
  final String email;
  final String password; // Note: In a real app, this should be hashed
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['Name'] as String,
      email: json['Email'] as String,
      password: json['Password'] as String,
      createdAt: DateTime.parse(json['Created At'] as String),
      updatedAt: DateTime.parse(json['Updated At'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Name': name,
      'Email': email,
      'Password': password,
      'Created At': createdAt.toIso8601String(),
      'Updated At': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
