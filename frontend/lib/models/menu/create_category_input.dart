class CreateCategoryInput {
  final String name;
  final int restaurantId;

  CreateCategoryInput({
    required this.name,
    required this.restaurantId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'restaurantId': restaurantId,
    };
  }
}