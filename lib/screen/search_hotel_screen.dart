// ---- COPY TỪ ĐÂY ĐỂ THAY THẾ PHẦN ĐẦU CỦA FILE search_hotel_screen.dart ----
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_travel_app/data/model/hotel.dart';
import 'package:fast_travel_app/widgets/hotel_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../config/default.dart';
import '../widgets/main_app_bar.dart';
import '../screen/room_detail.dart'; 

class SearchHotelScreen extends StatefulWidget {
  final String destination;
  final DateTimeRange? dateRange; 
  
  // --- THÊM 3 BIẾN NÀY ĐỂ HỨNG DỮ LIỆU ---
  final int rooms;
  final int adults;
  final int children;

  const SearchHotelScreen({
    super.key,
    this.destination = 'Đà Lạt',
    this.dateRange,
    // --- THÊM 3 DÒNG NÀY ĐỂ NHẬN GIÁ TRỊ TRUYỀN TỚI ---
    this.rooms = 1,
    this.adults = 2,
    this.children = 0,
  });

  @override
  State<SearchHotelScreen> createState() => _SearchHotelScreenState();
}
// ---- KẾT THÚC PHẦN COPY BƯỚC 1 ----

class _SearchHotelScreenState extends State<SearchHotelScreen> {
  
  // Hàm để tạo chuỗi hiển thị ngày: "24 thg 2 - 26 thg 2"
  String _formatDateRange(DateTimeRange? range) {
    if (range == null) return "Chọn ngày";
    final start = range.start;
    final end = range.end;
    return "${start.day} thg ${start.month} - ${end.day} thg ${end.month}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const MainAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 40),
              _buildFilterBar(),
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
              Expanded(
                child: _buildHotelList(),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildSearchOverlay(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchOverlay(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 30,
          width: double.infinity,
          color: colorPrimary,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 6), // Đổ bóng xuống đáy nhiều hơn theo yêu cầu trước
                )
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${widget.destination} - ${_formatDateRange(widget.dateRange)}', // Hiển thị ngày dynamic ở đây
                    style: TextStyle(
                      fontFamily: fontFamilyPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ... Giữ nguyên các hàm _buildFilterBar, _filterItem và _buildHotelList ...
  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 14, bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _filterItem('Sắp xếp'),
          _filterItem('Lọc'),
          _filterItem('Bản đồ'),
        ],
      ),
    );
  }

  Widget _filterItem(String label) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }

  Widget _buildHotelList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('hotels')
          .where('city', isEqualTo: widget.destination)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('Không tìm thấy chỗ nghỉ nào tại ${widget.destination}',
                  style: TextStyle(fontFamily: fontFamilyPrimary, color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Text(
                '${docs.length} chỗ nghỉ',
                style: TextStyle(
                  fontFamily: fontFamilyPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
           ...docs.map((doc) {
                try {
                  final hotel = Hotel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
                  
                  return InkWell(
                    onTap: () {
                      // CHUYỂN TRANG TẠI ĐÂY ĐỂ TRUYỀN ĐƯỢC widget.dateRange
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoomDetailScreen(
                            hotel: hotel,
                            dateRange: widget.dateRange, // Lấy ngày từ SearchHotelScreen truyền sang
                            rooms: widget.rooms, 
                            adults: widget.adults,
                            children: widget.children,
                          ),
                        ),
                      );
                    },
                    child: HotelCard(hotel: hotel), // Bọc cái card lại để nhấn vào là đi tiếp
                  );
                } catch (e) {
                  return const SizedBox.shrink();
                }
              }).toList(),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}