// finished_book_card.dart
import 'package:flutter/material.dart';

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
  final String roomImage; // asset path or network URL
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

  Widget _topInfoBand(BuildContext context) {
    TextStyle labelStyle = const TextStyle(
      color: _primaryBlue,
      fontWeight: FontWeight.bold,
    );
    TextStyle valueStyle = const TextStyle(
      color: _primaryBlue,
      fontWeight: FontWeight.w700,
    );

    return Container(
      color: _paleBlue,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ngày nhận phòng:', style: labelStyle),
                const SizedBox(height: 6),
                Text(checkIn, style: valueStyle),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ngày trả phòng:', style: labelStyle),
                const SizedBox(height: 6),
                Text(checkOut, style: valueStyle),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tình trạng:', style: labelStyle),
                const SizedBox(height: 6),
                Text(status, style: valueStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
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
    final cardBg = const Color(0xFFEAF6FF); // slightly different pale blue
    return GestureDetector(
      onTap: onTapRoom,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cardBg,
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
                  Text(
                    roomTitle,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Mã phòng: $roomCode',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    roomFloorAndHotel,
                    style: TextStyle(color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String pathOrUrl) {
    if (pathOrUrl.startsWith('http')) {
      return Image.network(pathOrUrl, fit: BoxFit.cover);
    } else {
      return Image.asset(pathOrUrl, fit: BoxFit.cover);
    }
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // top band
          _topInfoBand(context),
          // content padding
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Thông tin của bạn'),
                const SizedBox(height: 6),
                _guestInfo(),
                const SizedBox(height: 12),
                const Text(
                  'Phòng đã đặt',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                _roomCard(context),
                const SizedBox(height: 4),
                _addressBlock(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
