class CreateMenuItemInput {
  final String name;
  final String description;
  final String image;
  final double price;
  final int categoryId;

  CreateMenuItemInput({
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.categoryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'price': price,
      'categoryId': categoryId,
    };
  }
}