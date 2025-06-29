class RefreshTokenRequestApiModel {
  RefreshTokenRequestApiModel({required this.refreshToken});

  final String refreshToken;

  Map<String, dynamic> toJson() {
    return {'refreshToken': refreshToken};
  }
}
