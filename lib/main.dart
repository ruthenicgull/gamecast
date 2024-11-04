import 'package:flutter/material.dart';
import 'package:sangy/pages/auth_page.dart';
import 'package:sangy/pages/home_page.dart'; // Ensure you import the HomePage
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/auth', // Set the initial route
      routes: {
        '/auth': (context) => const AuthPage(), // Route for AuthPage
        '/home': (context) => const HomePage(), // Route for HomePage
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
            builder: (context) => const AuthPage()); // Fallback route
      },
    );
  }
}
