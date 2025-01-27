class Recipe {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String ingredients;

  Recipe({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.ingredients,
  });

  factory Recipe.fromFirestore(Map<String, dynamic> data, String id) {
    return Recipe(
      id: id,
      userId: data['userId'],
      title: data['title'],
      description: data['description'],
      ingredients: data['ingredients'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'ingredients': ingredients,
    };
  }
}
