class UserModel {
  final String id;
  final String username;
  final String email;
  final String password;
  final String? description;
  final bool isPremium;
  final String? photoUrl;
  final DateTime? birthDate;
  final String? gender;
  final String role;
  final bool isActive;
  final DateTime registrationDate;
  final List<String> followers;
  final List<String> following;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.description,
    this.isPremium = false,
    this.photoUrl,
    this.birthDate,
    this.gender,
    this.role = 'user',
    this.isActive = true,
    DateTime? registrationDate,
    List<String>? followers,
    List<String>? following,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : registrationDate = registrationDate ?? DateTime.now(),
        followers = followers ?? [],
        following = following ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      username: json['username'],
      email: json['email'],
      password: json['password'],
      description: json['description'],
      isPremium: json['isPremium'] ?? false,
      photoUrl: json['photoUrl'],
      birthDate:
          json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      gender: json['gender'],
      role: json['role'] ?? 'user',
      isActive: json['isActive'] ?? true,
      registrationDate: json['registrationDate'] != null
          ? DateTime.parse(json['registrationDate'])
          : null,
      followers:
          json['followers'] != null ? List<String>.from(json['followers']) : [],
      following:
          json['following'] != null ? List<String>.from(json['following']) : [],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'password': password,
      'description': description,
      'isPremium': isPremium,
      'photoUrl': photoUrl,
      'birthDate': birthDate?.toIso8601String(),
      'gender': gender,
      'role': role,
      'isActive': isActive,
      'registrationDate': registrationDate.toIso8601String(),
      'followers': followers,
      'following': following,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
    String? description,
    bool? isPremium,
    String? photoUrl,
    DateTime? birthDate,
    String? gender,
    String? role,
    bool? isActive,
    DateTime? registrationDate,
    List<String>? followers,
    List<String>? following,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      description: description ?? this.description,
      isPremium: isPremium ?? this.isPremium,
      photoUrl: photoUrl ?? this.photoUrl,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      registrationDate: registrationDate ?? this.registrationDate,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
