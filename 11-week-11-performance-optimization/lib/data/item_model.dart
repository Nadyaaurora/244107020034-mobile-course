class Item {
  final int id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;

  const Item({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
    };
  }
}
