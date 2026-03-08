import 'package:fast_travel_app/config/default.dart';
import 'package:fast_travel_app/widgets/main_app_bar.dart';
import 'package:flutter/material.dart';
import '../widgets/pending_booking_card.dart';
import '../widgets/finished_booking_card.dart';
import '../widgets/canceled_booking_card.dart';
import 'booking_detail_screen.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bookings = [
      {
        'id': 'N03',
        'title': 'Cây tre Villa Đà Lạt',
        'image': 'assets/images/hotels/cay_tre_villa_da_lat_1.png',
        'checkInLine': 'Ngày nhận phòng: T3, 25 thg 2',
        'subInfo': '1 đêm, 2 người lớn',
        'status': 'pending',
      },
      {
        'id': 'A12',
        'title': 'Villa Sunshine',
        'image': 'https://picsum.photos/300/200',
        'checkInLine': 'Ngày nhận phòng: T5, 27 thg 2',
        'subInfo': '2 đêm, 3 người lớn',
        'status': 'finished',
      },
      {
        'id': 'C55',
        'title': 'Beach Resort',
        'image': 'https://picsum.photos/300/210',
        'checkInLine': 'Ngày nhận phòng: CN, 20 thg 2',
        'subInfo': '3 đêm, 2 người lớn',
        'status': 'canceled',
      },
    ];

    final pending = bookings.where((b) => b['status'] == 'pending').toList();
    final finished = bookings.where((b) => b['status'] == 'finished').toList();
    final canceled = bookings.where((b) => b['status'] == 'canceled').toList();

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

            /// Tab content
            Expanded(
              child: TabBarView(
                children: [
                  _buildPendingList(context, pending),
                  _buildFinishedList(context, finished),
                  _buildCanceledList(context, canceled),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingList(BuildContext context, List bookings) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final b = bookings[index];

        return PendingBookingCard(
          imageUrl: b['image'],
          title: b['title'],
          checkInLine: b['checkInLine'],
          subInfo: b['subInfo'],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookingDetailScreen(
                  bookingId: b['id'],
                  title: b['title'],
                  imageUrl: b['image'],
                  checkIn: '',
                  checkOut: '',
                  status: 'pending',
                  guestName: '',
                  guestPhone: '',
                  guestEmail: '',
                  roomTitle: '',
                  roomCode: '',
                  roomFloorAndHotel: '',
                  roomImage: '',
                  address: '',
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFinishedList(BuildContext context, List bookings) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final b = bookings[index];

        return FinishedBookingCard(
          imageUrl: "assets/images/hotels/cay_tre_villa_da_lat_2.png",
          title: "Cây tre Villa Đà Lạt",
          subInfo: "1 đêm, 2 người lớn",
          checkIn: "T3, 25 thg 2",
          checkOut: "T3, 25 thg 2",
          onTap: () {},
          onReview: () {
            print("Write review pressed");
          },
        );
      },
    );
  }

  Widget _buildCanceledList(BuildContext context, List bookings) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final b = bookings[index];

        return CanceledBookingCard(
          dateTime: "T3, 25 thg 2 2026 · 17:08",
          hotelName: "Cây tre Villa Đà Lạt · TP. Đà Lạt",
          reason: "Muốn đổi khách sạn khác",
          onTap: () {
            print("Open canceled booking detail");
          },
        );
      },
    );
  }
}
