class Category {
  final String? id;
  final String name;
  final String icon;
  final String? description;
  final bool? isActive;

  Category({
    this.id,
    required this.name,
    required this.icon,
    this.description,
    this.isActive = true,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['name'],
      icon: json['icon'],
      description: json['description'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
      'description': description,
      'isActive': isActive,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? icon,
    String? description,
    bool? isActive,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}
