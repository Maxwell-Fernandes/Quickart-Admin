class Category {
  final String id;
  final String name;
  final String imageUrl;

  Category({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory Category.fromMap(Map<String, dynamic> data, String id) {
    return Category(
      id: id,
      name: data['category_name'] ?? '',
      imageUrl: data['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category_name': name,
      'image_url': imageUrl,
    };
  }
}
