import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:receipeapp/login_screen.dart';

import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('userId');
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data == true) {
          return HomeScreen(); // Redirect to Home if logged in
        } else {
          return LoginScreen(); // Redirect to Login if not logged in
        }
      },
    );
  }
}