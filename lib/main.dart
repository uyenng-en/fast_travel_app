import 'screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'screen/welcome_screen.dart';
import '../screen/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My app Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/welcome': (context) => const Welcome(),
        '/login': (context) => const Login(),
      },
      home: Scaffold(body: HomeScreen()),
    );
  }
}
