import 'package:fast_travel_app/screen/home_screen.dart';
import 'package:fast_travel_app/screen/hotel_manager_screen.dart';
import 'screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'screen/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const Login(),
        '/hotel_manager': (context) => const HotelManagerScreen(),
      },
      home: const HomeScreen(),
    );
  }
}
