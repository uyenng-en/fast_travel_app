import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_travel_app/data/model/hotel.dart';
import 'package:fast_travel_app/data/model/room_type.dart';
import 'package:flutter/material.dart';

class RoomTypeManagerScreen extends StatefulWidget {
  const RoomTypeManagerScreen({super.key});

  @override
  State<RoomTypeManagerScreen> createState() => _RoomTypeManagerScreenState();
}

class _RoomTypeManagerScreenState extends State<RoomTypeManagerScreen> {
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

  void _showRoomTypeDialog([RoomType? roomType]) {
    final isEditing = roomType != null;
    final nameController = TextEditingController(text: roomType?.roomName ?? '');
    final adultsController = TextEditingController(text: roomType?.maxAdults.toString() ?? '');
    final childrenController = TextEditingController(text: roomType?.maxChildren.toString() ?? '');
    final totalRoomsController = TextEditingController(text: roomType?.totalRooms.toString() ?? '');
    final priceController = TextEditingController(text: roomType?.basePrice.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Update Room Type' : 'Add Room Type'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Room Name'),
              ),
              TextField(
                controller: adultsController,
                decoration: const InputDecoration(labelText: 'Max Adults'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: childrenController,
                decoration: const InputDecoration(labelText: 'Max Children'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: totalRoomsController,
                decoration: const InputDecoration(labelText: 'Total Rooms'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Base Price'),
                keyboardType: TextInputType.number,
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
                'roomName': nameController.text,
                'maxAdults': int.tryParse(adultsController.text) ?? 0,
                'maxChildren': int.tryParse(childrenController.text) ?? 0,
                'totalRooms': int.tryParse(totalRoomsController.text) ?? 0,
                'basePrice': int.tryParse(priceController.text) ?? 0,
                'createdAt': isEditing ? roomType.createdAt : FieldValue.serverTimestamp(),
              };

              final roomTypesRef = _firestore
                  .collection('hotels')
                  .doc(_selectedHotelId)
                  .collection('roomTypes');

              if (isEditing) {
                await roomTypesRef.doc(roomType.id).update(data);
              } else {
                await roomTypesRef.add(data);
              }

              if (mounted) Navigator.pop(context);
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Type Manager'),
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
                ? const Center(child: Text('Select a hotel to see room types'))
                : StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('hotels')
                        .doc(_selectedHotelId)
                        .collection('roomTypes')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final roomTypeDocs = snapshot.data?.docs ?? [];

                      return ListView.builder(
                        itemCount: roomTypeDocs.length,
                        itemBuilder: (context, index) {
                          final doc = roomTypeDocs[index];
                          // Note: RoomType model might need hotelId in constructor if you still use it elsewhere
                          // For display here, we just need the data.
                          final data = doc.data() as Map<String, dynamic>;
                          final rt = RoomType(
                            id: doc.id,
                            hotelId: _selectedHotelId!,
                            roomName: data['roomName'] ?? '',
                            maxAdults: data['maxAdults'] ?? 0,
                            maxChildren: data['maxChildren'] ?? 0,
                            totalRooms: data['totalRooms'] ?? 0,
                            basePrice: data['basePrice'] ?? 0,
                            createdAt: data['createdAt'] ?? Timestamp.now(),
                          );
                          
                          return ListTile(
                            title: Text(rt.roomName),
                            subtitle: Text('Base Price: ${rt.basePrice} | Total: ${rt.totalRooms}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showRoomTypeDialog(rt),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await _firestore
                                        .collection('hotels')
                                        .doc(_selectedHotelId)
                                        .collection('roomTypes')
                                        .doc(rt.id)
                                        .delete();
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
        onPressed: _selectedHotelId == null ? null : () => _showRoomTypeDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
