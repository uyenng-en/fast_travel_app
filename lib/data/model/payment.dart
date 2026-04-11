import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

class Payment {
  final String id;
  final String userId;
  final String hotelId;
  final String bookingId;
  final int amount;
  final String currency;
  final PaymentState paymentStatus;
  final String? paymentMethod;
  final String? transactionRef;
  final Timestamp? paidAt;
  final Timestamp createdAt;

  Payment({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.bookingId,
    required this.amount,
    required this.currency,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.transactionRef,
    required this.paidAt,
    required this.createdAt,
  });

  factory Payment.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;
    return Payment(
      id: doc.id,
      userId: data['userId'],
      hotelId: data['hotelId'],
      bookingId: data['bookingId'],
      amount: data['amount'],
      currency: data['currency'],
      paymentStatus: PaymentStateX.fromFirestore(data['paymentStatus']),
      paymentMethod: data['paymentMethod'],
      transactionRef: data['transactionRef'],
      paidAt: data['paidAt'],
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'hotelId': hotelId,
    'bookingId': bookingId,
    'amount': amount,
    'currency': currency,
    'paymentStatus': paymentStatus.toFirestore(),
    'paymentMethod': paymentMethod,
    'transactionRef': transactionRef,
    'paidAt': paidAt,
    'createdAt': createdAt,
  };
}