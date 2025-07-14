class ImgurResponse {
  final String link;

  ImgurResponse({required this.link});

  factory ImgurResponse.fromJson(Map<String, dynamic> json) {
    return ImgurResponse(link: json['data']['link']);
  }
}
