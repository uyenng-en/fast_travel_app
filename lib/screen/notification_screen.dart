import 'package:flutter/material.dart';
import '../config/default.dart';
import 'package:fast_travel_app/widgets/sub_app_bar.dart';

// Giả sử NotificationCard được định nghĩa ở đây hoặc import vào
// (Mình tạm thời viết logic này để code không lỗi)

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // 1. Biến trạng thái để kiểm soát việc hiển thị
  bool hasNotification = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SubAppBar(title: "Thông báo"),
      backgroundColor: colorBackground,
      
      // 2. Dùng toán tử điều kiện để hiển thị body
      body: hasNotification ? _buildNotificationList() : _buildEmptyState(),

      // 3. Nút bấm tạm thời để bạn test bật/tắt
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorPrimary,
        onPressed: () {
          setState(() {
            hasNotification = !hasNotification; // Đảo ngược trạng thái
          });
        },
        child: Icon(
          hasNotification ? Icons.notifications_off : Icons.notifications_active,
          color: Colors.white,
        ),
      ),
    );
  }

  // Giao diện khi CHƯA có thông báo
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/img_no_notifications.png",
              width: 250,
              height: 250,
            ),
            const SizedBox(height: 16),
          
          ],
        ),
      ),
    );
  }

  // Giao diện khi ĐÃ có thông báo
  Widget _buildNotificationList() {
    return ListView( // Dùng ListView để có thể cuộn nếu nhiều thông báo
      padding: const EdgeInsets.all(16),
      children: [
        // Đây là cái Card bạn đã comment, mình mở ra và bọc lại
        _buildNotificationCard(
          title: "Phiếu giảm giá 10% cho người dùng mới",
          description: "Giảm đến 75,000 cho lần đặt vé máy bay đầu tiên và nhiều phần quà giá trị khác. Hãy nhanh tay chốt ngay!",
          time: "22:03",
          date: "01-02-2026",
          onTap: () => print("Notification clicked"),
        ),
      ],
    );
  }

  // Hàm phụ trợ tạo Card (vì bạn chưa cung cấp file NotificationCard)
  Widget _buildNotificationCard({
    required String title,
    required String description,
    required String time,
    required String date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date, style: const TextStyle(color: Colors.black45, fontSize: 11)),
                Text(time, style: const TextStyle(color: Colors.black45, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}