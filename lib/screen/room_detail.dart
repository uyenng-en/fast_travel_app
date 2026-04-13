import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/default.dart';
import '../data/model/hotel.dart'; 
import '../widgets/main_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomDetailScreen extends StatelessWidget {
  final Hotel hotel;
  final DateTimeRange? dateRange; // Nhận ngày từ trang search
  final int rooms;
  final int adults;
  final int children;

  const RoomDetailScreen({
    super.key, 
    required this.hotel,
    this.dateRange,
    this.rooms = 1,
    this.adults = 2,
    this.children = 0,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat("#,###", "vi_VN");

    TextStyle commonStyle({double fontSize = 14, FontWeight fontWeight = FontWeight.normal, Color? color}) {
      return TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    }

    return Scaffold(
      appBar: const MainAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(commonStyle),
            _buildImageGallery(),
            _buildFacilitiesSection(commonStyle),
            const Divider(thickness: 1, height: 1),
            _buildBookingInfoSection(commonStyle, currencyFormat), // Phần này sẽ dùng dữ liệu truyền vào
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(),
            ),
            _buildDescriptionSection(commonStyle),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(),
            ),
            _buildPolicySection(commonStyle),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(),
            ),
            _buildReviewSection(commonStyle),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildBottomButton(commonStyle),
    );
  }

  // --- Widget Components ---

  Widget _buildHeaderSection(Function style) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  hotel.hotelName,
                  style: style(fontSize: 22.0, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colorPrimary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('8.5', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ...List.generate(4, (index) => const Icon(Icons.star, color: Colors.amber, size: 18)),
              const Icon(Icons.star_half, color: Colors.amber, size: 18),
              const SizedBox(width: 8),
              Text('120 đánh giá', style: style(color: Colors.grey, fontSize: 13.0)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${hotel.address}, ${hotel.city}',
                  style: style(color: Colors.grey, fontSize: 13.0),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('hotels')
          .doc(hotel.id)
          .collection('images')
          .orderBy('sortOrder')
          .get(), // Lấy TẤT CẢ ảnh thay vì chỉ limit(1) như ở Card
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
          // Trường hợp không có ảnh nào trên Firebase
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _imgPlaceholder(180, width: double.infinity),
          );
        }

        // Lấy danh sách các đường dẫn ảnh
        List<String> imagePaths = snapshot.data!.docs
            .map((doc) => doc.get('imagePath') as String)
            .toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Ảnh lớn đầu tiên
              _buildRealImage(imagePaths[0], height: 180, width: double.infinity),
              const SizedBox(height: 8),
              
              // Hàng 3 ảnh nhỏ bên dưới (nếu có đủ ảnh)
              if (imagePaths.length > 1)
                Row(
                  children: [
                    Expanded(child: _buildRealImage(imagePaths[1], height: 80)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: imagePaths.length > 2
                          ? _buildRealImage(imagePaths[2], height: 80)
                          : _imgPlaceholder(80),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: imagePaths.length > 3
                          ? _buildRealImage(imagePaths[3], height: 80)
                          : _imgPlaceholder(80),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  // Hàm phụ trợ để hiển thị ảnh thật từ thư mục assets
  Widget _buildRealImage(String imagePath, {required double height, double? width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/images/hotels/$imagePath', // Thư mục chứa ảnh của bạn
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _imgPlaceholder(height, width: width),
        ),
      ),
    );
  }

  // Hộp xám dự phòng khi lỗi ảnh hoặc thiếu ảnh
  Widget _imgPlaceholder(double height, {double? width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.image, color: Colors.grey[400]),
    );
  }

  Widget _buildFacilitiesSection(Function style) {
    final am = hotel.amenities;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (am.hasWifi) _facilityItem(Icons.wifi, 'Wifi', style),
            if (am.hasShower) _facilityItem(Icons.shower_outlined, 'Vòi tắm', style),
            if (am.hasBath) _facilityItem(Icons.bathtub_outlined, 'Bồn tắm', style),
            if (am.hasFreeBreakfast) _facilityItem(Icons.restaurant, 'Ăn sáng', style),
            if (am.hasDailyCleaning) _facilityItem(Icons.cleaning_services_outlined, 'Dọn dẹp', style),
            if (am.hasElevator) _facilityItem(Icons.elevator, 'Thang máy', style),
          ],
        ),
      ),
    );
  }

  Widget _facilityItem(IconData icon, String label, Function style) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[100],
            child: Icon(icon, color: Colors.grey[800], size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: style(fontSize: 10.0), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // --- PHẦN CẬP NHẬT: HIỂN THỊ NGÀY VÀ KHÁCH DYNAMIC ---
  Widget _buildBookingInfoSection(Function style, NumberFormat fmt) {
    // Format ngày hiển thị
    String formatDate(DateTime? date) {
      if (date == null) return "Chưa chọn";
      return "Th ${date.weekday + 1}, ${date.day} thg ${date.month}";
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _dateInfo('Nhận phòng', formatDate(dateRange?.start), style),
              _dateInfo('Trả phòng', formatDate(dateRange?.end), style),
            ],
          ),
          const SizedBox(height: 16),
          Text('Số lượng phòng và khách', style: style(fontWeight: FontWeight.w600)),
          Text(
            '$rooms phòng, $adults người lớn, $children trẻ em', 
            style: style(color: Colors.blueAccent)
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statusTag('Cách trung tâm 3,5km', Colors.green, style),
              const SizedBox(width: 8),
              _statusTag('Hủy miễn phí', Colors.green, style),
            ],
          ),
          const SizedBox(height: 20),
          Text('Giá cho 1 đêm, $adults người lớn', style: style(color: Colors.grey)),
          Text(
            '${fmt.format(hotel.pricePerNight)} VND',
            style: style(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.redAccent),
          ),
          const Text('Đã bao gồm thuế và phí', style: TextStyle(fontSize: 12.0, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _dateInfo(String label, String date, Function style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: style(color: Colors.grey, fontSize: 13.0)),
        Text(date, style: style(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 15.0)),
      ],
    );
  }

  Widget _statusTag(String text, Color color, Function style) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(text, style: style(color: color, fontSize: 12.0, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildDescriptionSection(Function style) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Miêu tả', style: style(fontSize: 18.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(
            hotel.description ?? 'Thông tin mô tả đang được cập nhật...',
            style: style(color: Colors.black87).copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection(Function style) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chính sách', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _policyRowText('Nhận phòng:', 'từ 12:00 đến 14:00', style),
          _policyRowText('Trả phòng:', 'từ 00:00 đến 12:00', style),
          const SizedBox(height: 12),
          _freeTagRow('Có chỗ để xe miễn phí tại chỗ (cần đặt chỗ trước).', style),
          const SizedBox(height: 8),
          _freeTagRow('Wifi có ở toàn bộ khách sạn.', style),
        ],
      ),
    );
  }

  Widget _policyRowText(String label, String time, Function style) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(label, style: style(fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          Text(time, style: style()),
        ],
      ),
    );
  }

  Widget _freeTagRow(String content, Function style) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
          child: const Text('Miễn phí', style: TextStyle(color: Colors.white, fontSize: 10.0)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(content, style: style(fontSize: 14.0))),
      ],
    );
  }

  Widget _buildReviewSection(Function style) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Đánh giá của khách', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFF3B67A3), borderRadius: BorderRadius.circular(8)),
                child: const Text('8.5', style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rất tốt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),
                  Text(
                    'Xem tất cả đánh giá',
                    style: style(color: Colors.blue, fontSize: 13.0).copyWith(decoration: TextDecoration.underline)
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBottomButton(Function style) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: colorPrimary,
          minimumSize: const Size(double.infinity, 45),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'Chọn phòng',
          style: style(fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}