import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:receipeapp/receipe.dart';
import 'package:receipeapp/receipe_form_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  Future<void> logoutUser(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<String> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? '';
  }

  Future<List<Recipe>> fetchRecipes(String userId) async {
    final recipes = await FirebaseFirestore.instance
        .collection('recipes')
        .where('userId', isEqualTo: userId)
        .get();

    return recipes.docs
        .map((doc) => Recipe.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getUserId(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final userId = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text('My Recipes'),
            actions: [
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () => logoutUser(context),
              ),
            ],
          ),
          body: FutureBuilder<List<Recipe>>(
            future: fetchRecipes(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.data == null || snapshot.data!.isEmpty) {
                return Center(child: Text('No recipes found.'));
              }

              final recipes = snapshot.data!;
              return ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  return ListTile(
                    title: Text(recipe.title),
                    subtitle: Text(recipe.description),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('recipes')
                            .doc(recipe.id)
                            .delete();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Recipe deleted!')),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RecipeFormScreen(recipe: recipe),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecipeFormScreen()),
              );
            },
          ),
        );
      },
    );
  }
}
