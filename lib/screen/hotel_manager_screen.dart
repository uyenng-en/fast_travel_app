import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_travel_app/data/model/hotel.dart';
import 'package:flutter/material.dart';

class HotelManagerScreen extends StatefulWidget {
  const HotelManagerScreen({super.key});

  @override
  State<HotelManagerScreen> createState() => _HotelManagerScreenState();
}

class _HotelManagerScreenState extends State<HotelManagerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference<Hotel> _hotelsRef;

  @override
  void initState() {
    super.initState();
    _hotelsRef = _firestore.collection('hotels').withConverter<Hotel>(
          fromFirestore: (snapshot, _) => Hotel.fromFirestore(snapshot),
          toFirestore: (hotel, _) => hotel.toFirestore(),
        );
  }

  void _showHotelDialog([Hotel? hotel]) {
    final isEditing = hotel != null;
    final nameController = TextEditingController(text: hotel?.hotelName ?? '');
    final cityController = TextEditingController(text: hotel?.city ?? '');
    final addressController = TextEditingController(text: hotel?.address ?? '');
    final descriptionController =
        TextEditingController(text: hotel?.description ?? '');
    final priceController =
        TextEditingController(text: hotel?.pricePerNight.toString() ?? '');

    bool hasWifi = hotel?.amenities.hasWifi ?? false;
    bool hasShower = hotel?.amenities.hasShower ?? false;
    bool hasBath = hotel?.amenities.hasBath ?? false;
    bool hasFreeBreakfast = hotel?.amenities.hasFreeBreakfast ?? false;
    bool hasDailyCleaning = hotel?.amenities.hasDailyCleaning ?? false;
    bool hasElevator = hotel?.amenities.hasElevator ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Update Hotel' : 'Add Hotel'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Hotel Name'),
                ),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price Per Night'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Text('Amenities', style: TextStyle(fontWeight: FontWeight.bold)),
                CheckboxListTile(
                  title: const Text('Wifi'),
                  value: hasWifi,
                  onChanged: (val) => setState(() => hasWifi = val!),
                ),
                CheckboxListTile(
                  title: const Text('Shower'),
                  value: hasShower,
                  onChanged: (val) => setState(() => hasShower = val!),
                ),
                CheckboxListTile(
                  title: const Text('Bath'),
                  value: hasBath,
                  onChanged: (val) => setState(() => hasBath = val!),
                ),
                CheckboxListTile(
                  title: const Text('Free Breakfast'),
                  value: hasFreeBreakfast,
                  onChanged: (val) => setState(() => hasFreeBreakfast = val!),
                ),
                CheckboxListTile(
                  title: const Text('Daily Cleaning'),
                  value: hasDailyCleaning,
                  onChanged: (val) => setState(() => hasDailyCleaning = val!),
                ),
                CheckboxListTile(
                  title: const Text('Elevator'),
                  value: hasElevator,
                  onChanged: (val) => setState(() => hasElevator = val!),
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
                final amenities = HotelAmenities(
                  hasWifi: hasWifi,
                  hasShower: hasShower,
                  hasBath: hasBath,
                  hasFreeBreakfast: hasFreeBreakfast,
                  hasDailyCleaning: hasDailyCleaning,
                  hasElevator: hasElevator,
                );

                final Map<String, dynamic> hotelData = {
                  'hotelName': nameController.text,
                  'city': cityController.text,
                  'address': addressController.text,
                  'description': descriptionController.text,
                  'pricePerNight': int.tryParse(priceController.text) ?? 0,
                  'amenities': amenities.toMap(),
                  'updatedAt': FieldValue.serverTimestamp(),
                };

                if (!isEditing) {
                  hotelData['createdAt'] = FieldValue.serverTimestamp();
                  await _firestore.collection('hotels').add(hotelData);
                } else {
                  await _firestore.collection('hotels').doc(hotel.id).update(hotelData);
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

  Future<void> _deleteHotel(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Hotel'),
        content: const Text('Are you sure you want to delete this hotel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _hotelsRef.doc(id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Manager'),
      ),
      body: StreamBuilder<QuerySnapshot<Hotel>>(
        stream: _hotelsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final hotels = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: hotels.length,
            itemBuilder: (context, index) {
              final hotel = hotels[index].data();
              return ListTile(
                title: Text(hotel.hotelName),
                subtitle: Text('${hotel.city} - \$${hotel.pricePerNight}/night'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showHotelDialog(hotel),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteHotel(hotel.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showHotelDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
