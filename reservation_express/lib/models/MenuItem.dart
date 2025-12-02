class MenuItem {
  final int id;
  final String category;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final String? ingredients;
  final int? preparationTime;

  MenuItem({
    required this.id,
    required this.category,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.ingredients,
    this.preparationTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'preparationTime': preparationTime,
    };
  }

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      category: json['category'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'],
      ingredients: json['ingredients'],
      preparationTime: json['preparationTime'],
    );
  }
}
