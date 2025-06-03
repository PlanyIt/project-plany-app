class Category {
  final String id;
  final String name;
  final String icon;
  final String color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    this.color = "3425B5",
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['name'],
      icon: json['icon'],
      color: json['color'] ?? "3425B5",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
    };
  }
}
