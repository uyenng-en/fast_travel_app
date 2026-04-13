import 'package:fast_travel_app/screen/admin_screen.dart';
import 'package:fast_travel_app/screen/home_screen.dart';
import 'package:fast_travel_app/screen/hotel_manager_screen.dart';
import 'package:fast_travel_app/screen/paycheck.dart';
import 'package:fast_travel_app/screen/payform.dart';
import 'package:fast_travel_app/screen/payment_success.dart';
import 'package:fast_travel_app/screen/room_type_manager_screen.dart';
import 'package:fast_travel_app/screen/hotel_review_manager_screen.dart';
import 'package:fast_travel_app/screen/search_screen.dart';
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
        '/admin': (context) => const AdminScreen(),
        '/hotel_manager': (context) => const HotelManagerScreen(),
        '/room_type_manager': (context) => const RoomTypeManagerScreen(),
        '/review_manager': (context) => const HotelReviewManagerScreen(),
      },
      home: const HomeScreen(),
      // home: const AdminScreen(),
    );
  }
}
