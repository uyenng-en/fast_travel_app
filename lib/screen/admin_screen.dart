import 'package:flutter/material.dart';
import 'hotel_manager_screen.dart';
import 'room_type_manager_screen.dart';
import 'hotel_review_manager_screen.dart';
import '../widgets/app_drawer.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      drawer: AppDrawer(context: context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildAdminCard(
              context,
              'Manage Hotels',
              Icons.hotel,
              Colors.blue,
              const HotelManagerScreen(),
            ),
            _buildAdminCard(
              context,
              'Room Types',
              Icons.room_service,
              Colors.green,
              const RoomTypeManagerScreen(),
            ),
            _buildAdminCard(
              context,
              'Hotel Reviews',
              Icons.rate_review,
              Colors.orange,
              const HotelReviewManagerScreen(),
            ),
            // You can add more management cards here as needed
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget targetScreen,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetScreen),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
