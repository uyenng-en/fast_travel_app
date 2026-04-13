import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_travel_app/config/default.dart';
import 'package:fast_travel_app/widgets/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/pending_booking_card.dart';
import '../widgets/finished_booking_card.dart';
import '../widgets/canceled_booking_card.dart';
import 'booking_detail_screen.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: const MainAppBar(),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              child: const TabBar(
                labelColor: Colors.black,
                indicatorColor: Colors.blue,
                tabs: [
                  Tab(text: "Đang hoạt động"),
                  Tab(text: "Đã qua"),
                  Tab(text: "Đã hủy"),
                ],
              ),
            ),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
                  }

                  final allBookings = snapshot.data?.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final hotelSnap = data['hotelSnapshot'] as Map<String, dynamic>?;
                    final checkIn = (data['checkinDate'] as Timestamp?)?.toDate();
                    final checkOut = (data['checkoutDate'] as Timestamp?)?.toDate();

                    String checkInFormatted = checkIn != null 
                        ? DateFormat("E, d 'thg' M", 'vi_VN').format(checkIn)
                        : 'Chưa rõ ngày';

                    return {
                      'id': doc.id,
                      'hotelId': data['hotelId'],
                      'title': hotelSnap?['hotelName'] ?? 'Khách sạn',
                      'checkInLine': 'Ngày nhận phòng: $checkInFormatted',
                      'checkInShort': checkInFormatted, 
                      'checkOutShort': checkOut != null ? DateFormat("E, d 'thg' M", 'vi_VN').format(checkOut) : "",
                      'subInfo': '${checkOut?.difference(checkIn!).inDays ?? 1} đêm, ${data['adultsCount']} người lớn',
                      'status': data['bookingStatus'] == 'CONFIRMED' ? 'pending' 
                              : data['bookingStatus'] == 'completed' ? 'finished' : 'canceled',
                      'createdAt': data['createdAt'],
                      'reason': data['cancellationReason'] ?? "N/A",
                      'rawData': data, // --- LỖI TẠI ĐÂY: BẠN CẦN THÊM DÒNG NÀY ---
                    };
                  }).toList() ?? [];

                  final pending = allBookings.where((b) => b['status'] == 'pending').toList();
                  final finished = allBookings.where((b) => b['status'] == 'finished').toList();
                  final canceled = allBookings.where((b) => b['status'] == 'canceled').toList();

                  return TabBarView(
                    children: [
                      _buildPendingList(context, pending),
                      _buildFinishedList(context, finished),
                      _buildCanceledList(context, canceled),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingList(BuildContext context, List bookings) {
    if (bookings.isEmpty) return const Center(child: Text("Không có đơn đặt phòng nào"));
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final b = bookings[index];

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('hotels').doc(b['hotelId']).collection('images')
              .orderBy('sortOrder').limit(1).get(),
          builder: (context, imgSnap) {
            String imgPath = 'assets/images/hotels/cay_tre_villa_da_lat_1.png';
            if (imgSnap.hasData && imgSnap.data!.docs.isNotEmpty) {
              imgPath = 'assets/images/hotels/${imgSnap.data!.docs.first.get('imagePath')}';
            }

            return PendingBookingCard(
              imageUrl: imgPath,
              title: b['title'],
              checkInLine: b['checkInLine'],
              subInfo: b['subInfo'],
              onTap: () {
                final Map<String, dynamic> raw = (b['rawData'] as Map<String, dynamic>?) ?? {};

                if (raw.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Không tìm thấy dữ liệu chi tiết của đơn này')),
                  );
                  return;
                }

                final hotelSnap = (raw['hotelSnapshot'] as Map<String, dynamic>?) ?? {};
                final roomSnap = (raw['roomSnapshot'] as Map<String, dynamic>?) ?? {};

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingDetailScreen(
                      bookingId: b['id'],
                      title: b['title'],
                      imageUrl: imgPath,
                      checkIn: b['checkInShort'],
                      checkOut: b['checkOutShort'],
                      status: raw['bookingStatus'] ?? 'N/A',
                      // Chú ý: Lấy thông tin user đã lưu trong booking (từ trang payform truyền qua)
                      guestName: "${raw['lastName'] ?? ''} ${raw['firstName'] ?? 'Khách'}", 
                      guestPhone: raw['phoneNumber'] ?? 'N/A',
                      guestEmail: raw['email'] ?? 'N/A',
                      roomTitle: roomSnap['roomName'] ?? 'Phòng tiêu chuẩn',
                      roomCode: b['id'].substring(0, 5).toUpperCase(),
                      roomFloorAndHotel: b['title'],
                      roomImage: imgPath,
                      address: hotelSnap['address'] ?? 'N/A',
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ... Giữ nguyên các hàm _buildFinishedList và _buildCanceledList của bạn ...
  Widget _buildFinishedList(BuildContext context, List bookings) {
    if (bookings.isEmpty) return const Center(child: Text("Chưa có lịch sử đặt phòng"));
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final b = bookings[index];
        return FinishedBookingCard(
          imageUrl: "assets/images/hotels/cay_tre_villa_da_lat_2.png",
          title: b['title'],
          subInfo: b['subInfo'],
          checkIn: b['checkInShort'],
          checkOut: b['checkOutShort'],
          onTap: () {},
          onReview: () {},
        );
      },
    );
  }

  Widget _buildCanceledList(BuildContext context, List bookings) {
    if (bookings.isEmpty) return const Center(child: Text("Không có đơn bị hủy"));
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final b = bookings[index];
        final Timestamp? createdAt = b['createdAt'];
        return CanceledBookingCard(
          dateTime: createdAt != null 
              ? DateFormat("E, d 'thg' M yyyy · HH:mm", 'vi_VN').format(createdAt.toDate())
              : "",
          hotelName: b['title'],
          reason: b['reason'],
          onTap: () {},
        );
      },
    );
  }
}