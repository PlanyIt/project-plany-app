class User {
  final String token;

  User({
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      token: json['access_token'], // Utilise 'access_token' renvoyé par l'API
    );
  }
}
