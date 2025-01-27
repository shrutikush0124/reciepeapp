import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lib/models/recipe.dart';

class RecipeFormScreen extends StatelessWidget {
  final Recipe? recipe;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController ingredientsController = TextEditingController();

  RecipeFormScreen({this.recipe}) {
    if (recipe != null) {
      titleController.text = recipe!.title;
      descriptionController.text = recipe!.description;
      ingredientsController.text = recipe!.ingredients;
    }
  }

  Future<String> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? '';
  }

  Future<void> saveRecipe(BuildContext context) async {
    final userId = await getUserId();
    final recipeData = {
      'userId': userId,
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'ingredients': ingredientsController.text.trim(),
    };

    final recipes = FirebaseFirestore.instance.collection('recipes');

    if (recipe == null) {
      await recipes.add(recipeData);
    } else {
      await recipes.doc(recipe!.id).update(recipeData);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Recipe saved!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe == null ? 'Add Recipe' : 'Edit Recipe'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Recipe Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: ingredientsController,
              decoration: InputDecoration(labelText: 'Ingredients'),
              maxLines: 4,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => saveRecipe(context),
              child: Text('Save Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}
