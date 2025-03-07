class Plan {
  final String? id;
  final String title;
  final String description;
  final String photo;


  Plan({
    this.id,
    required this.title,
    required this.description,
    required this.photo,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      photo: json['photo'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'photo': photo,
    };
  }
}
