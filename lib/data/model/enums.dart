enum PaymentState { pending, paid, failed, refunded }

enum PaymentTiming { beforeCheckin, duringStay, afterCheckout }

enum BookingStatus { confirmed, cancelled, completed }

extension PaymentStateX on PaymentState {
  String toFirestore() => name;

  static PaymentState fromFirestore(String value) {
    return PaymentState.values.firstWhere(
          (e) => e.name == value,
      orElse: () => PaymentState.pending,
    );
  }
}

extension PaymentTimingX on PaymentTiming {
  String toFirestore() => name;

  static PaymentTiming fromFirestore(String value) {
    return PaymentTiming.values.firstWhere(
          (e) => e.name == value,
      orElse: () => PaymentTiming.beforeCheckin,
    );
  }
}

extension BookingStatusX on BookingStatus {
  String toFirestore() => name;

  static BookingStatus fromFirestore(String value) {
    return BookingStatus.values.firstWhere(
          (e) => e.name == value,
      orElse: () => BookingStatus.confirmed,
    );
  }
}