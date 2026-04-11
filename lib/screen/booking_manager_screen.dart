import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_travel_app/data/model/booking.dart';
import 'package:fast_travel_app/data/model/enums.dart';
import 'package:flutter/material.dart';

class BookingManagerScreen extends StatefulWidget {
  const BookingManagerScreen({super.key});

  @override
  State<BookingManagerScreen> createState() => _BookingManagerScreenState();
}

class _BookingManagerScreenState extends State<BookingManagerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showBookingDialog([Booking? booking]) {
    final isEditing = booking != null;
    BookingStatus status = booking?.bookingStatus ?? BookingStatus.confirmed;
    PaymentState pState = booking?.paymentState ?? PaymentState.pending;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Update Booking' : 'Add Booking (Manual)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<BookingStatus>(
                value: status,
                decoration: const InputDecoration(labelText: 'Booking Status'),
                items: BookingStatus.values.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s.name));
                }).toList(),
                onChanged: (val) => setState(() => status = val!),
              ),
              DropdownButtonFormField<PaymentState>(
                value: pState,
                decoration: const InputDecoration(labelText: 'Payment State'),
                items: PaymentState.values.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s.name));
                }).toList(),
                onChanged: (val) => setState(() => pState = val!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (isEditing) {
                  await _firestore.collection('bookings').doc(booking.id).update({
                    'bookingStatus': status.toFirestore(),
                    'paymentState': pState.toFirestore(),
                    'updatedAt': FieldValue.serverTimestamp(),
                  });
                }
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Manager')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('bookings').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final booking = Booking.fromFirestore(docs[index] as DocumentSnapshot<Map<String, dynamic>>);
              return ListTile(
                title: Text('${booking.hotelSnapshot.hotelName} - ${booking.id.substring(0, 8)}'),
                subtitle: Text('Status: ${booking.bookingStatus.name} | Total: \$${booking.totalPrice}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showBookingDialog(booking),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _firestore.collection('bookings').doc(booking.id).delete(),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
