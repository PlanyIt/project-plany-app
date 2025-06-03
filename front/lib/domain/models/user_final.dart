class UserModel {
  final String id;
  final String email;
  final String username;
  final String? description;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? password;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.description,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
    this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      description: json['description'],
      photoUrl: json['photoUrl'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'description': description,
      'photoUrl': photoUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'password': password,
    };
  }
}
