class UpdateMenuItemInput {
  final String? name;
  final String? description;
  final String? image;
  final double? price;

  UpdateMenuItemInput({
    this.name,
    this.description,
    this.image,
    this.price,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (image != null) data['image'] = image;
    if (price != null) data['price'] = price;
    return data;
  }
}