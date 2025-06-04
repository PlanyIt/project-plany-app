class User {
  final String id;
  String username;
  final String email;
  final String? password;
  String? description;
  String? photoUrl;
  DateTime? birthDate;
  String? gender;
  final String role;
  final bool isActive;
  final DateTime registrationDate;
  final List<String> followers;
  final List<String> following;
  int? followersCount;
  int? followingCount;
  int? plansCount;
  int? favoritesCount;
  bool isPremium;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.password,
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
    this.followersCount,
    this.followingCount,
    this.plansCount,
    this.favoritesCount,
    this.createdAt, // Ajout au constructeur
    this.updatedAt, // Ajout au constructeur
  })  : registrationDate = registrationDate ?? DateTime.now(),
        followers = followers ?? [],
        following = following ?? [];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
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
      followersCount: json['followersCount'] ?? json['followers']?.length,
      followingCount: json['followingCount'] ?? json['following']?.length,
      plansCount: json['plansCount'],
      favoritesCount: json['favoritesCount'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null, // Conversion du champ createdAt
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null, // Conversion du champ updatedAt
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
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
      'plansCount': plansCount,
      'favoritesCount': favoritesCount,
      'createdAt': createdAt?.toIso8601String(), // Ajout au toJson
      'updatedAt': updatedAt?.toIso8601String(), // Ajout au toJson
    };
  }

  // Helper pour récupérer le nombre de followers
  int get getFollowersCount => followersCount ?? followers.length;

  // Helper pour récupérer le nombre de following
  int get getFollowingCount => followingCount ?? following.length;

  // Créer une copie de l'utilisateur avec des champs mis à jour
  User copyWith({
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
    int? followersCount,
    int? followingCount,
    int? plansCount,
    int? favoritesCount,
    DateTime? createdAt, // Ajout au copyWith
    DateTime? updatedAt, // Ajout au copyWith
  }) {
    return User(
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
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      plansCount: plansCount ?? this.plansCount,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      createdAt: createdAt ?? this.createdAt, // Ajout au retour de copyWith
      updatedAt: updatedAt ?? this.updatedAt, // Ajout au retour de copyWith
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email)';
  }
}
