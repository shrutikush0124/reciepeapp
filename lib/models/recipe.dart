class Recipe {
  final int? id;
  final String title;
  final String description;
  final String? imagePath; // Image path
  final String? ingredients; // Comma-separated ingredients

  Recipe({
    this.id,
    required this.title,
    required this.description,
    this.imagePath,
    this.ingredients,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imagePath': imagePath,
      'ingredients': ingredients,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      imagePath: map['imagePath'],
      ingredients: map['ingredients'],
    );
  }
}
