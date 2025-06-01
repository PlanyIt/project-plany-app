class User {
  final String? id;
  final String? username;
  final String? email;
  final String? firebaseUid;
  final String? description;
  final String? role;
  final DateTime? registrationDate;
  final bool? isActive;
  final String? avatarUrl;
  final String? location;

  User({
    this.id,
    this.username,
    this.email,
    this.firebaseUid,
    this.description,
    this.role,
    this.registrationDate,
    this.isActive,
    this.avatarUrl,
    this.location,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['username'],
      email: json['email'],
      firebaseUid: json['firebaseUid'],
      description: json['description'],
      role: json['role'],
      registrationDate: json['registrationDate'] != null
          ? DateTime.parse(json['registrationDate'])
          : null,
      isActive: json['isActive'],
      avatarUrl: json['avatarUrl'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'firebaseUid': firebaseUid,
      'description': description,
      'role': role,
      'isActive': isActive,
      'avatarUrl': avatarUrl,
      'location': location,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? firebaseUid,
    String? description,
    String? role,
    DateTime? registrationDate,
    bool? isActive,
    String? avatarUrl,
    String? location,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      description: description ?? this.description,
      role: role ?? this.role,
      registrationDate: registrationDate ?? this.registrationDate,
      isActive: isActive ?? this.isActive,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      location: location ?? this.location,
    );
  }
}
