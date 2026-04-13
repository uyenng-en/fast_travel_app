import 'package:flutter/material.dart';
import '../config/default.dart';
import '../widgets/main_app_bar.dart';

class BookingSuccessScreen extends StatelessWidget {
  final String totalPrice;
  final String bookingId;
  final String bookingDate;
  final String status;
  final String email;

  const BookingSuccessScreen({
    super.key,
    required this.totalPrice, // Yêu cầu truyền vào
    required this.bookingId,
    required this.bookingDate,
    required this.status,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    const successGreen = Color(0xFF4CAF50);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const MainAppBar(), // Sử dụng AppBar chung của bạn
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon Check màu xanh
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: successGreen, width: 3),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: successGreen,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      "Đặt phòng thành công!",
                      style: TextStyle(
                        color: successGreen,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      "Chúc mừng bạn đã đặt phòng thành công, vui lòng chú ý điện thoại hoặc email trước ngày nhận 1 - 2 ngày để xác nhận phòng nhé !",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- KHỐI DỮ LIỆU ĐỘNG ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow("Số tiền", totalPrice, isTotal: true),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(height: 1, color: Color(0xFFE0E0E0)),
                          ),
                          _buildDetailRow("Mã phòng", bookingId),
                          const SizedBox(height: 16),
                          _buildDetailRow("Ngày đặt", bookingDate),
                          const SizedBox(height: 16),
                          _buildDetailRow("Tình trạng", status),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- HIỂN THỊ EMAIL ĐỘNG ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF2FA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Hóa đơn sẽ được gửi vào email $email",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF5A789A),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Quay về màn hình đầu tiên (SearchScreen)
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimary, // Dùng màu từ default.dart
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Trở về trang chủ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF666666), fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.black87,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}