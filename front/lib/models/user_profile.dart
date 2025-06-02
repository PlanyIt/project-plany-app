class UserProfile {
  String id;
  String? mongoId;
  String username;
  final String email;
  String? photoUrl;
  String? description;
  DateTime? birthDate;
  String? gender;
  bool isPremium;
  final DateTime? createdAt;
  
  List<String> followers;
  List<String> following;
  int? followersCount;
  int? followingCount;
  int? plansCount;
  int? favoritesCount;

  UserProfile({
    required this.id,
    this.mongoId,
    required this.username,
    required this.email,
    this.photoUrl,
    this.description,
    this.birthDate,
    this.gender,
    this.isPremium = false,
    this.createdAt,
    this.followers = const [],
    this.following = const [],
    this.followersCount,
    this.followingCount,
    this.plansCount,
    this.favoritesCount,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['firebaseUid'] ?? json['id'], 
      mongoId: json['_id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
      description: json['description'],
      birthDate:
          json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      gender: json['gender'],
      isPremium: json['isPremium'] ?? false,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      followers: json['followers'] != null 
          ? List<String>.from(json['followers'].map((f) => f is Map ? f['_id'] ?? f['id'] : f.toString()))
          : [],
      following: json['following'] != null 
          ? List<String>.from(json['following'].map((f) => f is Map ? f['_id'] ?? f['id'] : f.toString()))
          : [],
      followersCount: json['followersCount'] ?? json['followers']?.length,
      followingCount: json['followingCount'] ?? json['following']?.length,
      plansCount: json['plansCount'] ?? 0,
      favoritesCount: json['favoritesCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mongoId': mongoId,
      'username': username,
      'email': email,
      'photoUrl': photoUrl,
      'description': description,
      'birthDate': birthDate?.toIso8601String(),
      'gender': gender,
      'isPremium': isPremium,
      'createdAt': createdAt?.toIso8601String(),
      'followers': followers,
      'following': following,
      'followersCount': followersCount ?? followers.length,
      'followingCount': followingCount ?? following.length,
      'plansCount': plansCount ?? 0,
      'favoritesCount': favoritesCount ?? 0,
    };
  }
}