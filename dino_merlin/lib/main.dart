import 'package:dino_merlin/Pages/Auth/login_page.dart';
import 'package:dino_merlin/Pages/BottomBar/bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dino',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        splashFactory: NoSplash.splashFactory,
      ),
      home: InitialScreen(),
    );
  }
}

class InitialScreen extends StatelessWidget {
  Future<bool> _checkRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool rememberMe = prefs.getBool('rememberMe') ?? false;
    User? user = FirebaseAuth.instance.currentUser;
    return rememberMe && user != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkRememberMe(),
      builder: (context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          if (snapshot.data == true) {
            return const BottomNavBar();
          } else {
            return const LoginPage();
          }
        }
      },
    );
  }
}
