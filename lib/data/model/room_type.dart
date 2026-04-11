import 'package:cloud_firestore/cloud_firestore.dart';

class RoomType {
  final String id;
  final String hotelId;
  final String roomName;
  final int maxAdults;
  final int maxChildren;
  final int totalRooms;
  final int basePrice;
  final Timestamp createdAt;

  RoomType({
    required this.id,
    required this.hotelId,
    required this.roomName,
    required this.maxAdults,
    required this.maxChildren,
    required this.totalRooms,
    required this.basePrice,
    required this.createdAt,
  });

  factory RoomType.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;
    return RoomType(
      id: doc.id,
      hotelId: data['hotelId'],
      roomName: data['roomName'],
      maxAdults: data['maxAdults'],
      maxChildren: data['maxChildren'],
      totalRooms: data['totalRooms'],
      basePrice: data['basePrice'],
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'hotelId': hotelId,
    'roomName': roomName,
    'maxAdults': maxAdults,
    'maxChildren': maxChildren,
    'totalRooms': totalRooms,
    'basePrice': basePrice,
    'createdAt': createdAt,
  };
}