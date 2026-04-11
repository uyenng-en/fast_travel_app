import 'package:cloud_firestore/cloud_firestore.dart';

class HotelAmenities {
  final bool hasWifi;
  final bool hasShower;
  final bool hasBath;
  final bool hasFreeBreakfast;
  final bool hasDailyCleaning;
  final bool hasElevator;

  HotelAmenities({
    required this.hasWifi,
    required this.hasShower,
    required this.hasBath,
    required this.hasFreeBreakfast,
    required this.hasDailyCleaning,
    required this.hasElevator,
  });

  factory HotelAmenities.fromMap(Map<String, dynamic> map) {
    return HotelAmenities(
      hasWifi: map['hasWifi'] ?? false,
      hasShower: map['hasShower'] ?? false,
      hasBath: map['hasBath'] ?? false,
      hasFreeBreakfast: map['hasFreeBreakfast'] ?? false,
      hasDailyCleaning: map['hasDailyCleaning'] ?? false,
      hasElevator: map['hasElevator'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'hasWifi': hasWifi,
    'hasShower': hasShower,
    'hasBath': hasBath,
    'hasFreeBreakfast': hasFreeBreakfast,
    'hasDailyCleaning': hasDailyCleaning,
    'hasElevator': hasElevator,
  };
}

class Hotel {
  final String id;
  final String hotelName;
  final String city;
  final String address;
  final String? description;
  final int pricePerNight;
  final HotelAmenities amenities;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Hotel({
    required this.id,
    required this.hotelName,
    required this.city,
    required this.address,
    required this.description,
    required this.pricePerNight,
    required this.amenities,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Hotel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};
    return Hotel(
      id: doc.id,
      hotelName: data['hotelName'] ?? 'No Name',
      city: data['city'] ?? 'Unknown City',
      address: data['address'] ?? '',
      description: data['description'],
      pricePerNight: data['pricePerNight'] ?? 0,
      amenities: HotelAmenities.fromMap(
        Map<String, dynamic>.from(data['amenities'] ?? {}),
      ),
      // Handle null timestamps (common during initial creation)
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'hotelName': hotelName,
    'city': city,
    'address': address,
    'description': description,
    'pricePerNight': pricePerNight,
    'amenities': amenities.toMap(),
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}
