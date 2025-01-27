import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/user.dart';
import '../../models/recipe.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._();
  static Database? _db;

  DBHelper._();

  factory DBHelper() => _instance;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'app.db'),
      onCreate: (db, version) async {
        // Create users table
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT
          )
        ''');

        // Create recipes table
        await db.execute('''
          CREATE TABLE recipes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            imagePath TEXT,
            ingredients TEXT
          )
        ''');
      },
      version: 1,
    );
  }

  // User CRUD Operations
  Future<int> insertUser(User user) async {
    final db = await database;
    return db.insert('users', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> getUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // Recipe CRUD Operations
  Future<int> insertRecipe(Recipe recipe) async {
    final db = await database;
    return db.insert('recipes', recipe.toMap());
  }

  Future<List<Recipe>> getRecipes() async {
    final db = await database;
    final result = await db.query('recipes');
    return result.map((e) => Recipe.fromMap(e)).toList();
  }

  Future<Recipe?> getRecipeById(int id) async {
    final db = await database;
    final result = await db.query(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Recipe.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateRecipe(Recipe recipe) async {
    final db = await database;
    return db.update(
      'recipes',
      recipe.toMap(),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }

  Future<int> deleteRecipe(int id) async {
    final db = await database;
    return db.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
