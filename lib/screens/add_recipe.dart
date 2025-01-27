import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../database/db_helper.dart';
import '../models/recipe.dart';

class AddRecipeScreen extends StatefulWidget {
  final Recipe? recipe;
  final Function onSave;

  AddRecipeScreen({this.recipe, required this.onSave});

  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController ingredientsController = TextEditingController();
  final DBHelper dbHelper = DBHelper();
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      titleController.text = widget.recipe!.title;
      descriptionController.text = widget.recipe!.description;
      ingredientsController.text = widget.recipe!.ingredients ?? '';
      if (widget.recipe!.imagePath != null &&
          widget.recipe!.imagePath!.isNotEmpty) {
        selectedImage = File(widget.recipe!.imagePath!);
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> _saveRecipe() async {
    final title = titleController.text;
    final description = descriptionController.text;
    final ingredients =
        ingredientsController.text.split(',').map((e) => e.trim()).toList();

    if (title.isNotEmpty &&
        description.isNotEmpty &&
        selectedImage != null &&
        ingredients.isNotEmpty) {
      if (widget.recipe == null) {
        // Add new recipe
        await dbHelper.insertRecipe(
          Recipe(
            title: title,
            description: description,
            imagePath: selectedImage!.path,
            ingredients: ingredients.toString(),
          ),
        );
      } else {
        // Update existing recipe
        await dbHelper.updateRecipe(
          Recipe(
            id: widget.recipe!.id,
            title: title,
            description: description,
            imagePath: selectedImage!.path,
            ingredients: ingredients.toString(),
          ),
        );
      }

      widget.onSave();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select an image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe == null ? 'Add Recipe' : 'Edit Recipe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Recipe Title'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextField(
                controller: ingredientsController,
                decoration:
                    InputDecoration(labelText: 'Ingredients (comma-separated)'),
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: selectedImage == null
                      ? Center(child: Text('Tap to select an image'))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _saveRecipe,
                  child: Text(widget.recipe == null ? 'Add' : 'Update'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
