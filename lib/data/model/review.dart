import 'package:cloud_firestore/cloud_firestore.dart';

class HotelReview {
  final String id;
  final String hotelId;
  final String userId;
  final double rating;
  final String? comment;
  final Timestamp createdAt;

  HotelReview({
    required this.id,
    required this.hotelId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory HotelReview.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;
    return HotelReview(
      id: doc.id,
      hotelId: data['hotelId'],
      userId: data['userId'],
      rating: (data['rating'] as num).toDouble(),
      comment: data['comment'],
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'hotelId': hotelId,
    'userId': userId,
    'rating': rating,
    'comment': comment,
    'createdAt': createdAt,
  };
}