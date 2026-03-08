import 'package:fast_travel_app/screen/search_screen.dart';
import 'package:flutter/material.dart';
import 'notification_screen.dart';
import 'booking_history_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    Center(child: BookingHistoryScreen()),
    Center(child: SearchScreen()),
    Center(child: NotificationScreen()),
    Center(child: ProfileScreen()),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // optional: override defaults
        // iconSize: 28,
        // selectedColor: Colors.green,
      ),
    );
  }
}
