import 'package:flutter/material.dart';

class CanceledBookingCard extends StatelessWidget {
  final String dateTime;
  final String hotelName;
  final String reason;
  final VoidCallback? onTap;

  const CanceledBookingCard({
    Key? key,
    required this.dateTime,
    required this.hotelName,
    required this.reason,
    this.onTap,
  }) : super(key: key);

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE04A4A),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        "Đã hủy phòng",
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Top row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateTime,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            _buildStatusBadge(),
          ],
        ),

        const SizedBox(height: 8),

        /// Hotel name
        Text(
          hotelName,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),

        const SizedBox(height: 6),

        /// Cancellation reason
        Text(
          "Lý do: $reason",
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildContent(),
    );

    return GestureDetector(onTap: onTap, child: card);
  }
}
