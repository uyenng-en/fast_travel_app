import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/main_app_bar.dart';

class BookingDetailScreen extends StatelessWidget {
  final String bookingId;
  final String title;
  final String imageUrl;
  final String checkIn;
  final String checkOut;
  final String status;
  final String guestName;
  final String guestPhone;
  final String guestEmail;
  final String roomTitle;
  final String roomCode;
  final String roomFloorAndHotel;
  final String roomImage;
  final String address;
  final VoidCallback? onTapRoom;

  const BookingDetailScreen({
    Key? key,
    required this.bookingId,
    required this.title,
    required this.imageUrl,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    required this.guestName,
    required this.guestPhone,
    required this.guestEmail,
    required this.roomTitle,
    required this.roomCode,
    required this.roomFloorAndHotel,
    required this.roomImage,
    required this.address,
    this.onTapRoom,
  }) : super(key: key);

  static const Color _paleBlue = Color(0xFFDFF3FF);
  static const Color _primaryBlue = Color(0xFF0B72C1);

  // --- LOGIC XỬ LÝ HỦY PHÒNG TRÊN FIREBASE ---
  void _handleCancelBooking(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lý do hủy phòng', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Nhập lý do của bạn tại đây...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy bỏ', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập lý do hủy')),
                );
                return;
              }

              // Hiện Loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );

              try {
                // Cập nhật lên Firebase
                await FirebaseFirestore.instance
                    .collection('bookings')
                    .doc(bookingId)
                    .update({
                  'bookingStatus': 'canceled',
                  'cancellationReason': reasonController.text.trim(),
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                if (context.mounted) {
                  Navigator.pop(context); // Tắt loading
                  Navigator.pop(context); // Tắt dialog nhập lý do
                  Navigator.pop(context); // Quay về trang lịch sử
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã hủy phòng thành công')),
                  );
                }
              } catch (e) {
                Navigator.pop(context); // Tắt loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi khi hủy: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xác nhận hủy', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _topInfoBand(BuildContext context) {
    TextStyle labelStyle = const TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold);
    TextStyle valueStyle = const TextStyle(color: _primaryBlue, fontWeight: FontWeight.w700);

    return Container(
      color: _paleBlue,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        children: [
          _infoRow('Ngày nhận phòng:', checkIn, labelStyle, valueStyle),
          const SizedBox(height: 8),
          _infoRow('Ngày trả phòng:', checkOut, labelStyle, valueStyle),
          const SizedBox(height: 8),
          _infoRow(
            'Tình trạng:',
            status == 'CONFIRMED' ? 'Thanh toán khi trả phòng' : status,
            labelStyle,
            valueStyle,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, TextStyle lStyle, TextStyle vStyle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: lStyle),
        Text(value, style: vStyle),
      ],
    );
  }

  Widget _guestInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(guestName, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(guestPhone),
        const SizedBox(height: 2),
        Text(guestEmail),
      ],
    );
  }

  Widget _roomCard(BuildContext context) {
    return GestureDetector(
      onTap: onTapRoom,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF6FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 84,
                height: 64,
                child: _buildImage(roomImage),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(roomTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('Mã phòng: $roomCode', style: TextStyle(color: Colors.grey[700])),
                  const SizedBox(height: 6),
                  Text(roomFloorAndHotel,
                      style: TextStyle(color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String pathOrUrl) {
    if (pathOrUrl.isEmpty) return Container(color: Colors.grey[300], child: const Icon(Icons.image));
    return pathOrUrl.startsWith('http')
        ? Image.network(pathOrUrl, fit: BoxFit.cover)
        : Image.asset(pathOrUrl, fit: BoxFit.cover);
  }

  Widget _addressBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Địa chỉ', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(address),
        const SizedBox(height: 8),
        Text(
          'Để nhận phòng vui lòng liên hệ lễ tân vào ngày nhận phòng',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _supportSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bạn cần hỗ trợ ?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          // CHÈN LOGIC HỦY VÀO ĐÂY
          _supportItem(
            Icons.cancel_presentation_outlined, 
            'Tôi muốn hủy phòng',
            onTap: status == 'CONFIRMED' ? () => _handleCancelBooking(context) : null,
            color: status == 'CONFIRMED' ? Colors.black87 : Colors.grey,
          ),
          const Divider(height: 24),
          _supportItem(Icons.phone_outlined, 'Liên hệ khách sạn'),
          const Divider(height: 24),
          _supportItem(Icons.help_outline, 'Trung tâm hỗ trợ'),
        ],
      ),
    );
  }

  Widget _supportItem(IconData icon, String label, {VoidCallback? onTap, Color color = Colors.black87}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 15, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const MainAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              color: Colors.white,
              margin: const EdgeInsets.all(14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _topInfoBand(context),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Thông tin của bạn', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        _guestInfo(),
                        const SizedBox(height: 12),
                        const Text('Phòng đã đặt', style: TextStyle(fontWeight: FontWeight.w600)),
                        _roomCard(context),
                        const SizedBox(height: 4),
                        _addressBlock(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _supportSection(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}