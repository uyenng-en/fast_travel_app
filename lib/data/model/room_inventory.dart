import 'package:cloud_firestore/cloud_firestore.dart';

class RoomInventory {
  final String id;
  final String roomTypeId;
  final Timestamp inventoryDate;
  final int availableRooms;

  RoomInventory({
    required this.id,
    required this.roomTypeId,
    required this.inventoryDate,
    required this.availableRooms,
  });

  factory RoomInventory.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;
    return RoomInventory(
      id: doc.id,
      roomTypeId: data['roomTypeId'],
      inventoryDate: data['inventoryDate'],
      availableRooms: data['availableRooms'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'roomTypeId': roomTypeId,
    'inventoryDate': inventoryDate,
    'availableRooms': availableRooms,
  };
}