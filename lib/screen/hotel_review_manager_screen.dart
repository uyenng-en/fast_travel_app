import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_travel_app/data/model/hotel.dart';
import 'package:fast_travel_app/data/model/review.dart';
import 'package:flutter/material.dart';

class HotelReviewManagerScreen extends StatefulWidget {
  const HotelReviewManagerScreen({super.key});

  @override
  State<HotelReviewManagerScreen> createState() => _HotelReviewManagerScreenState();
}

class _HotelReviewManagerScreenState extends State<HotelReviewManagerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedHotelId;
  List<Hotel> _hotels = [];

  @override
  void initState() {
    super.initState();
    _loadHotels();
  }

  Future<void> _loadHotels() async {
    final snapshot = await _firestore.collection('hotels').get();
    setState(() {
      _hotels = snapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
      if (_hotels.isNotEmpty) {
        _selectedHotelId = _hotels.first.id;
      }
    });
  }

  String _getRatingText(double rating) {
    if (rating >= 9.0) return 'Xuất sắc';
    if (rating >= 8.0) return 'Rất tốt';
    if (rating >= 7.0) return 'Tốt';
    if (rating >= 5.0) return 'Trung bình';
    if (rating >= 3.0) return 'Tệ';
    return 'Rất tệ';
  }

  void _showReviewDialog([HotelReview? review]) {
    final isEditing = review != null;
    final userIdController = TextEditingController(text: review?.userId ?? '');
    final commentController = TextEditingController(text: review?.comment ?? '');
    double rating = review?.rating ?? 7.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Update Review' : 'Add Review'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: userIdController,
                  decoration: const InputDecoration(labelText: 'User ID'),
                ),
                const SizedBox(height: 16),
                Text('Rating: ${rating.toStringAsFixed(1)} (${_getRatingText(rating)})'),
                Slider(
                  value: rating,
                  min: 1,
                  max: 10,
                  divisions: 90, // Allows 0.1 increments
                  label: rating.toStringAsFixed(1),
                  onChanged: (val) => setState(() => rating = val),
                ),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(labelText: 'Comment'),
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
                if (_selectedHotelId == null) return;

                final data = {
                  'hotelId': _selectedHotelId,
                  'userId': userIdController.text,
                  'rating': rating,
                  'comment': commentController.text,
                  'createdAt': isEditing ? review.createdAt : FieldValue.serverTimestamp(),
                };

                if (isEditing) {
                  await _firestore.collection('reviews').doc(review.id).update(data);
                } else {
                  await _firestore.collection('reviews').add(data);
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
      appBar: AppBar(
        title: const Text('Hotel Review Manager'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedHotelId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Select Hotel'),
              items: _hotels.map((hotel) {
                return DropdownMenuItem(
                  value: hotel.id,
                  child: Text(
                    hotel.hotelName,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedHotelId = val);
              },
            ),
          ),
          Expanded(
            child: _selectedHotelId == null
                ? const Center(child: Text('Select a hotel to see reviews'))
                : StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('reviews')
                        .where('hotelId', isEqualTo: _selectedHotelId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final reviewDocs = snapshot.data?.docs ?? [];

                      return ListView.builder(
                        itemCount: reviewDocs.length,
                        itemBuilder: (context, index) {
                          final doc = reviewDocs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final r = HotelReview(
                            id: doc.id,
                            hotelId: data['hotelId'] ?? '',
                            userId: data['userId'] ?? '',
                            rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
                            comment: data['comment'],
                            createdAt: data['createdAt'] ?? Timestamp.now(),
                          );

                          return ListTile(
                            title: Text('Rating: ${r.rating.toStringAsFixed(1)} (${_getRatingText(r.rating)})'),
                            subtitle: Text(r.comment ?? 'No comment'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showReviewDialog(r),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await _firestore.collection('reviews').doc(r.id).delete();
                                  },
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
        onPressed: _selectedHotelId == null ? null : () => _showReviewDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
