import 'package:cloud_firestore/cloud_firestore.dart';

class HotelImage {
  final String id;
  final String imagePath;
  final int sortOrder;
  final Timestamp createdAt;

  HotelImage({
    required this.id,
    required this.imagePath,
    required this.sortOrder,
    required this.createdAt,
  });

  factory HotelImage.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;
    return HotelImage(
      id: doc.id,
      imagePath: data['imagePath'],
      sortOrder: data['sortOrder'],
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'imagePath': imagePath,
    'sortOrder': sortOrder,
    'createdAt': createdAt,
  };
}