import 'menu_item.dart';

class ItemsCategory {
  final int id;
  final String name;
  final int restaurantId;
  final List<MenuItem>? items;

  ItemsCategory({
    required this.id,
    required this.name,
    required this.restaurantId,
    this.items,
  });

  factory ItemsCategory.fromJson(Map<String, dynamic> json) {
    return ItemsCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      restaurantId: json['restaurantId'] ?? 0,
      items: json['items'] != null
          ? (json['items'] as List<dynamic>)
              .map((item) => MenuItem.fromJson(item))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'restaurantId': restaurantId,
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }

  ItemsCategory copyWith({
    int? id,
    String? name,
    int? restaurantId,
    List<MenuItem>? items,
  }) {
    return ItemsCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      restaurantId: restaurantId ?? this.restaurantId,
      items: items ?? this.items,
    );
  }
}