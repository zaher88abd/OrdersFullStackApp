import 'category.dart';

class MenuItem {
  final int id;
  final String name;
  final String description;
  final String image;
  final double price;
  final int categoryId;
  final ItemsCategory? category;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.categoryId,
    this.category,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      categoryId: json['categoryId'] ?? 0,
      category: json['category'] != null 
          ? ItemsCategory.fromJson(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'price': price,
      'categoryId': categoryId,
      'category': category?.toJson(),
    };
  }

  MenuItem copyWith({
    int? id,
    String? name,
    String? description,
    String? image,
    double? price,
    int? categoryId,
    ItemsCategory? category,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
    );
  }
}