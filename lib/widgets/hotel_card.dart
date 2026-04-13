// file: lib/widgets/hotel_card.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_travel_app/data/model/hotel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HotelCard extends StatelessWidget {
  final Hotel hotel;

  const HotelCard({super.key, required this.hotel});

  String _getRatingText(double rating) {
    if (rating >= 9.0) return 'Xuất sắc';
    if (rating >= 8.0) return 'Rất tốt';
    if (rating >= 7.0) return 'Tốt';
    if (rating >= 5.0) return 'Trung bình';
    if (rating >= 3.0) return 'Tệ';
    return 'Rất tệ';
  }

  @override
  Widget build(BuildContext context) {
    // KHÔNG CÓ InkWell HAY Navigator.push NÀO Ở ĐÂY NỮA
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageSection(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            hotel.hotelName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.favorite_border, color: Colors.black, size: 26),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildRatingSection(),
                    const SizedBox(height: 8),
                    _buildDistanceBadge(),
                    const Spacer(),
                    _buildPriceSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... Giữ nguyên các hàm _buildImageSection, _buildRatingSection, v.v. bên dưới của bạn ...
  Widget _buildImageSection() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('hotels')
          .doc(hotel.id)
          .collection('images')
          .orderBy('sortOrder')
          .limit(1)
          .get(),
      builder: (context, snapshot) {
        String? imagePath;
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          imagePath = snapshot.data!.docs.first.get('imagePath');
        }

        return Container(
          width: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey[200],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: imagePath != null
                ? Image.asset(
                    'assets/images/hotels/$imagePath',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Center(child: Icon(Icons.hotel, size: 50, color: Colors.grey)),
                  )
                : const Center(child: Icon(Icons.hotel, size: 50, color: Colors.grey)),
          ),
        );
      },
    );
  }

  Widget _buildRatingSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('hotelId', isEqualTo: hotel.id)
          .snapshots(),
      builder: (context, snapshot) {
        double avgRating = 0;
        int reviewCount = 0;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          reviewCount = snapshot.data!.docs.length;
          double totalRating = 0;
          for (var doc in snapshot.data!.docs) {
            totalRating += (doc.get('rating') as num).toDouble();
          }
          avgRating = totalRating / reviewCount;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < (avgRating / 2).floor() ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                );
              }),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B5296),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    avgRating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getRatingText(avgRating),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Text(' • ', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Text(
                    '$reviewCount đánh giá',
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildDistanceBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'Cách trung tâm 3,5km',
        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPriceSection() {
    final formatter = NumberFormat('###,###');
    return Align(
      alignment: Alignment.bottomRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'Giá cho 1 đêm, 2 người lớn',
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
          Text(
            '${formatter.format(hotel.pricePerNight)} VND',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Text(
            'Đã bao gồm thuế và phí',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Hủy miễn phí',
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
