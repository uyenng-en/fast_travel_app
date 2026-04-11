import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

class HotelSnapshot {
  final String hotelName;
  final String city;
  final String address;
  final int pricePerNight;

  HotelSnapshot({
    required this.hotelName,
    required this.city,
    required this.address,
    required this.pricePerNight,
  });

  factory HotelSnapshot.fromMap(Map<String, dynamic> map) {
    return HotelSnapshot(
      hotelName: map['hotelName'],
      city: map['city'],
      address: map['address'],
      pricePerNight: map['pricePerNight'],
    );
  }

  Map<String, dynamic> toMap() => {
    'hotelName': hotelName,
    'city': city,
    'address': address,
    'pricePerNight': pricePerNight,
  };
}

class RoomSnapshot {
  final String roomName;
  final int maxAdults;
  final int maxChildren;

  RoomSnapshot({
    required this.roomName,
    required this.maxAdults,
    required this.maxChildren,
  });

  factory RoomSnapshot.fromMap(Map<String, dynamic> map) {
    return RoomSnapshot(
      roomName: map['roomName'],
      maxAdults: map['maxAdults'],
      maxChildren: map['maxChildren'],
    );
  }

  Map<String, dynamic> toMap() => {
    'roomName': roomName,
    'maxAdults': maxAdults,
    'maxChildren': maxChildren,
  };
}

class Booking {
  final String id;
  final String userId;
  final String hotelId;
  final String? roomTypeId;

  final Timestamp checkinDate;
  final Timestamp checkoutDate;
  final int roomsCount;
  final int adultsCount;
  final int childrenCount;
  final Timestamp bookingDate;

  final PaymentState paymentState;
  final PaymentTiming? paymentTiming;
  final BookingStatus bookingStatus;

  final int totalPrice;
  final Timestamp? cancelledAt;
  final String? cancellationReason;

  final HotelSnapshot hotelSnapshot;
  final RoomSnapshot? roomSnapshot;

  final Timestamp createdAt;
  final Timestamp updatedAt;

  Booking({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.roomTypeId,
    required this.checkinDate,
    required this.checkoutDate,
    required this.roomsCount,
    required this.adultsCount,
    required this.childrenCount,
    required this.bookingDate,
    required this.paymentState,
    required this.paymentTiming,
    required this.bookingStatus,
    required this.totalPrice,
    required this.cancelledAt,
    required this.cancellationReason,
    required this.hotelSnapshot,
    required this.roomSnapshot,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;
    return Booking(
      id: doc.id,
      userId: data['userId'],
      hotelId: data['hotelId'],
      roomTypeId: data['roomTypeId'],
      checkinDate: data['checkinDate'],
      checkoutDate: data['checkoutDate'],
      roomsCount: data['roomsCount'],
      adultsCount: data['adultsCount'],
      childrenCount: data['childrenCount'],
      bookingDate: data['bookingDate'],
      paymentState: PaymentStateX.fromFirestore(data['paymentState']),
      paymentTiming: data['paymentTiming'] == null
          ? null
          : PaymentTimingX.fromFirestore(data['paymentTiming']),
      bookingStatus: BookingStatusX.fromFirestore(data['bookingStatus']),
      totalPrice: data['totalPrice'],
      cancelledAt: data['cancelledAt'],
      cancellationReason: data['cancellationReason'],
      hotelSnapshot: HotelSnapshot.fromMap(
        Map<String, dynamic>.from(data['hotelSnapshot']),
      ),
      roomSnapshot: data['roomSnapshot'] == null
          ? null
          : RoomSnapshot.fromMap(
        Map<String, dynamic>.from(data['roomSnapshot']),
      ),
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'hotelId': hotelId,
    'roomTypeId': roomTypeId,
    'checkinDate': checkinDate,
    'checkoutDate': checkoutDate,
    'roomsCount': roomsCount,
    'adultsCount': adultsCount,
    'childrenCount': childrenCount,
    'bookingDate': bookingDate,
    'paymentState': paymentState.toFirestore(),
    'paymentTiming': paymentTiming?.toFirestore(),
    'bookingStatus': bookingStatus.toFirestore(),
    'totalPrice': totalPrice,
    'cancelledAt': cancelledAt,
    'cancellationReason': cancellationReason,
    'hotelSnapshot': hotelSnapshot.toMap(),
    'roomSnapshot': roomSnapshot?.toMap(),
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}