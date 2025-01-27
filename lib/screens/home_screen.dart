import 'dart:io';
import 'package:flutter/material.dart';
import 'package:receipeapp/screens/add_recipe.dart';
import 'package:receipeapp/screens/login_screen.dart';
import '../database/db_helper.dart';
import '../models/recipe.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Recipe> recipes = [];
  final DBHelper dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    final fetchedRecipes = await dbHelper.getRecipes();
    setState(() {
      recipes = fetchedRecipes;
    });
  }

  Future<void> _deleteRecipe(int id, BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Delete Recipe'),
          content: Text('Are you sure you want to delete this recipe?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await dbHelper.deleteRecipe(id);
                Navigator.of(context).pop();
                _fetchRecipes();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'My Recipes',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black87),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    title: Text('Logout'),
                    content: Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child:
                            Text('Logout', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: recipes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No recipes added yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap + to add your first recipe',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.only(top: 16, bottom: 88),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: Offset(0, 3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: recipe.imagePath != null &&
                                  recipe.imagePath!.isNotEmpty
                              ? Image.file(
                                  File(recipe.imagePath!),
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.restaurant,
                                    size: 50,
                                    color: Colors.grey[400],
                                  ),
                                ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    recipe.title,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon:
                                      Icon(Icons.edit, color: Colors.blue[400]),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddRecipeScreen(
                                          recipe: recipe,
                                          onSave: _fetchRecipes,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete,
                                      color: Colors.red[400]),
                                  onPressed: () =>
                                      _deleteRecipe(recipe.id!, context),
                                ),
                              ],
                            ),
                            if (recipe.description.isNotEmpty) ...[
                              SizedBox(height: 8),
                              Text(
                                recipe.description,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                              ),
                            ],
                            SizedBox(height: 16),
                            Text(
                              'Ingredients',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: recipe.ingredients!
                                    .split(',')
                                    .map((ingredient) => Container(
                                          margin: EdgeInsets.only(right: 8),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.restaurant,
                                                size: 16,
                                                color: Colors.grey[600],
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                ingredient.trim(),
                                                style: TextStyle(
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddRecipeScreen(onSave: _fetchRecipes),
            ),
          );
        },
        icon: Icon(Icons.add),
        label: Text('Add Recipe'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
