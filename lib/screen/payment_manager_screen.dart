import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_travel_app/data/model/booking.dart';
import 'package:fast_travel_app/data/model/payment.dart';
import 'package:fast_travel_app/data/model/enums.dart';
import 'package:flutter/material.dart';

class PaymentManagerScreen extends StatefulWidget {
  const PaymentManagerScreen({super.key});

  @override
  State<PaymentManagerScreen> createState() => _PaymentManagerScreenState();
}

class _PaymentManagerScreenState extends State<PaymentManagerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedBookingId;
  List<Booking> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final snapshot = await _firestore.collection('bookings').get();
    setState(() {
      _bookings = snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
      if (_bookings.isNotEmpty) {
        _selectedBookingId = _bookings.first.id;
      }
    });
  }

  void _showPaymentDialog([Payment? payment]) {
    final isEditing = payment != null;
    final amountController = TextEditingController(text: payment?.amount.toString() ?? '');
    final currencyController = TextEditingController(text: payment?.currency ?? 'USD');
    final methodController = TextEditingController(text: payment?.paymentMethod ?? '');
    final refController = TextEditingController(text: payment?.transactionRef ?? '');
    PaymentState status = payment?.paymentStatus ?? PaymentState.pending;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Update Payment' : 'Add Payment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: currencyController,
                  decoration: const InputDecoration(labelText: 'Currency'),
                ),
                DropdownButtonFormField<PaymentState>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: PaymentState.values.map((s) {
                    return DropdownMenuItem(value: s, child: Text(s.name));
                  }).toList(),
                  onChanged: (val) => setState(() => status = val!),
                ),
                TextField(
                  controller: methodController,
                  decoration: const InputDecoration(labelText: 'Payment Method'),
                ),
                TextField(
                  controller: refController,
                  decoration: const InputDecoration(labelText: 'Transaction Ref'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_selectedBookingId == null) return;
                final booking = _bookings.firstWhere((b) => b.id == _selectedBookingId);

                final data = {
                  'userId': booking.userId,
                  'hotelId': booking.hotelId,
                  'amount': int.tryParse(amountController.text) ?? 0,
                  'currency': currencyController.text,
                  'paymentStatus': status.toFirestore(),
                  'paymentMethod': methodController.text,
                  'transactionRef': refController.text,
                  'paidAt': status == PaymentState.paid ? FieldValue.serverTimestamp() : null,
                  'updatedAt': FieldValue.serverTimestamp(),
                };

                final paymentsRef = _firestore
                    .collection('bookings')
                    .doc(_selectedBookingId)
                    .collection('payments');

                if (isEditing) {
                  await paymentsRef.doc(payment.id).update(data);
                } else {
                  data['createdAt'] = FieldValue.serverTimestamp();
                  await paymentsRef.add(data);
                }

                if (mounted) Navigator.pop(context);
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Manager')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedBookingId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Select Booking'),
              items: _bookings.map((b) {
                return DropdownMenuItem(
                  value: b.id,
                  child: Text('ID: ${b.id.substring(0, 8)} | ${b.hotelSnapshot.hotelName}'),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedBookingId = val),
            ),
          ),
          Expanded(
            child: _selectedBookingId == null
                ? const Center(child: Text('Select a booking to see payments'))
                : StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('bookings')
                        .doc(_selectedBookingId)
                        .collection('payments')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final docs = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final p = Payment(
                            id: doc.id,
                            userId: data['userId'] ?? '',
                            hotelId: data['hotelId'] ?? '',
                            bookingId: _selectedBookingId!,
                            amount: data['amount'] ?? 0,
                            currency: data['currency'] ?? 'USD',
                            paymentStatus: PaymentStateX.fromFirestore(data['paymentStatus'] ?? 'pending'),
                            paymentMethod: data['paymentMethod'],
                            transactionRef: data['transactionRef'],
                            paidAt: data['paidAt'],
                            createdAt: data['createdAt'] ?? Timestamp.now(),
                          );

                          return ListTile(
                            title: Text('Amount: ${p.amount} ${p.currency}'),
                            subtitle: Text('Status: ${p.paymentStatus.name} | Method: ${p.paymentMethod ?? "N/A"}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showPaymentDialog(p),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _firestore
                                      .collection('bookings')
                                      .doc(_selectedBookingId)
                                      .collection('payments')
                                      .doc(p.id)
                                      .delete(),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectedBookingId == null ? null : () => _showPaymentDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
