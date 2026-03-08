import 'package:flutter/material.dart';

class FinishedBookingCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subInfo;
  final String checkIn;
  final String checkOut;
  final VoidCallback? onTap;
  final VoidCallback? onReview;

  const FinishedBookingCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.subInfo,
    required this.checkIn,
    required this.checkOut,
    this.onTap,
    this.onReview,
  }) : super(key: key);

  Widget _buildImage() {
    final isNetwork = imageUrl.startsWith('http');

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 110,
        height: 110,
        child: isNetwork
            ? Image.network(imageUrl, fit: BoxFit.cover)
            : Image.asset(imageUrl, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildInfo() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Hotel title
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 6),

            /// Guest info row
            Row(
              children: [
                const Icon(Icons.person_outline, size: 18),
                const SizedBox(width: 6),
                Text(subInfo, style: const TextStyle(fontSize: 14)),
              ],
            ),

            const SizedBox(height: 12),

            /// Check in / check out
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Nhận phòng",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(checkIn),
                  ],
                ),

                const Text("— — — — —"),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Trả phòng",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(checkOut),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onReview,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE7D27F),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
        ),
        child: const Text(
          "Viết đánh giá",
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          /// Top row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildImage(), _buildInfo()],
          ),

          const SizedBox(height: 18),

          /// Review button
          _buildReviewButton(),
        ],
      ),
    );

    return GestureDetector(onTap: onTap, child: card);
  }
}
