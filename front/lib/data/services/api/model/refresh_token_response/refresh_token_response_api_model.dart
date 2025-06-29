class RefreshTokenResponseApiModel {
  const RefreshTokenResponseApiModel({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory RefreshTokenResponseApiModel.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponseApiModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}
