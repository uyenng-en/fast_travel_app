import 'package:fast_travel_app/config/default.dart';
import 'package:fast_travel_app/data/model/hotel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_success.dart';

class Paycheck extends StatelessWidget {
  final Hotel hotel;
  final DateTimeRange? dateRange;
  final int rooms;
  final int adults;
  final int children;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final int totalPrice; // Biến này vẫn giữ để nhận từ trang trước, nhưng ta sẽ tính lại cho chắc chắn

  const Paycheck({
    super.key,
    required this.hotel,
    this.dateRange,
    required this.rooms,
    required this.adults,
    required this.children,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat("#,###", "vi_VN");

    TextStyle style({int size = 14, FontWeight weight = FontWeight.normal, Color color = Colors.black}) {
      return TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: size.toDouble(),
        fontWeight: weight,
        color: color,
      );
    }
    
    // Format ngày hiển thị
    String formatDate(DateTime? date) {
      if (date == null) return "Chưa chọn";
      List<String> weekdays = ["CN", "Th 2", "Th 3", "Th 4", "Th 5", "Th 6", "Th 7"];
      return "${weekdays[date.weekday % 7]}, ${date.day} thg ${date.month}";
    }
    
    String dateDisplay = dateRange != null ? "${formatDate(dateRange!.start)} - ${formatDate(dateRange!.end)}" : "Chưa chọn ngày";

    // LOGIC TÍNH TOÁN SỐ ĐÊM VÀ TỔNG TIỀN TẠI ĐÂY
    int nights = 1;
    if (dateRange != null) {
      // Lấy ngày trả trừ đi ngày nhận để ra số đêm
      nights = dateRange!.end.difference(dateRange!.start).inDays;
      // Đảm bảo số đêm tối thiểu là 1 (trường hợp đặt và trả cùng 1 ngày)
      if (nights <= 0) nights = 1; 
    }
    
    // Công thức: Giá 1 đêm x Số đêm x Số phòng
    int finalCalculatedPrice = hotel.pricePerNight * nights * rooms;


  List<String> availableAmenities = [];
    final am = hotel.amenities;
    
    if (am.hasWifi) availableAmenities.add('Wifi');
    if (am.hasShower) availableAmenities.add('Vòi tắm');
    if (am.hasBath) availableAmenities.add('Bồn tắm');
    if (am.hasFreeBreakfast) availableAmenities.add('Bữa sáng miễn phí');
    if (am.hasDailyCleaning) availableAmenities.add('Dọn dẹp');
    if (am.hasElevator) availableAmenities.add('Thang máy');

    // Nếu có tiện nghi thì ghép lại bằng dấu phẩy, nếu không thì báo "Không có"
    String amenitiesText = availableAmenities.isNotEmpty 
        ? availableAmenities.join(', ') 
        : 'Không có thông tin';


    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: colorPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chi tiết đặt phòng',
          style: style(size: 18, weight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kiểm tra lại thông tin của bạn', style: style(size: 18, weight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Phòng
                  Row(
                    children: [
                    // THAY THẾ KHỐI CONTAINER CŨ BẰNG ĐOẠN FUTUREBUILDER NÀY
                      FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('hotels')
                            .doc(hotel.id)
                            .collection('images')
                            .orderBy('sortOrder')
                            .limit(1)
                            .get(),
                        builder: (context, snapshot) {
                          // Nếu đang tải hoặc không có ảnh -> Hiện ô màu xám (Placeholder)
                          if (snapshot.connectionState == ConnectionState.waiting ||
                              !snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.hotel, color: Colors.grey),
                            );
                          }

                          // Nếu có ảnh -> Hiện ảnh thật
                          String imagePath = snapshot.data!.docs.first.get('imagePath');
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(4), // Bo góc cho giống thiết kế
                            child: Image.asset(
                              'assets/images/hotels/$imagePath',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Icon(Icons.hotel, color: Colors.grey),
                              ),
                            ),
                          );
                        },
                      ),
                      // KẾT THÚC PHẦN THAY THẾ
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hotel.hotelName, style: style(size: 16, weight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(dateDisplay, style: style(weight: FontWeight.bold, size: 14, color: colorPrimary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Dữ liệu người dùng
                  _buildReviewRow('Tên khách', '$lastName $firstName', style, isAction: true),
                  _buildReviewRow('Liên hệ', '$phone\n$email', style),
                  _buildReviewRow('Số lượng', '$rooms phòng, $adults người lớn, $children trẻ em', style),
                  _buildReviewRow('Tiện nghi', amenitiesText, style),
                  _buildReviewRow('Hủy phòng', 'Miễn phí hủy trong vòng 3 ngày.', style, colorValue: Colors.green),
                  const Divider(height: 32),

                  // HIỂN THỊ RÕ RÀNG BẢNG TÍNH TIỀN
                  _buildPriceRow('Giá cho 1 đêm', 'VND ${currencyFormat.format(hotel.pricePerNight)}', style, isBold: false),
                  const SizedBox(height: 8),
                  _buildPriceRow('Thời gian lưu trú', '$nights đêm', style, isBold: false),
                  if (rooms > 1) ...[
                    const SizedBox(height: 8),
                    _buildPriceRow('Số lượng phòng', '$rooms phòng', style, isBold: false),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(height: 1),
                  ),
                  _buildPriceRow('Tổng thanh toán', 'VND ${currencyFormat.format(finalCalculatedPrice)}', style, isBold: true),
                ],
              ),
            ),
          ],
        ),
      ),
      // Truyền tổng tiền đã tính toán chính xác xuống dưới nút xác nhận
      bottomSheet: _buildBottomAction(
        context, 
        style, 
        currencyFormat.format(finalCalculatedPrice), 
        finalCalculatedPrice, 
        currencyFormat
      ),
    );
  }

  Widget _buildReviewRow(String label, String value, Function style, {bool isAction = false, Color? colorValue}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: style(size: 14, weight: FontWeight.bold, color: Colors.black87)),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(value, style: style(size: 14, color: colorValue ?? Colors.black87)),
                ),
                if (isAction)
                  Text('Thay đổi', style: style(size: 12, weight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String price, Function style, {required bool isBold}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style(size: 14, color: isBold ? Colors.black : Colors.grey[600], weight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(price, style: style(size: 14, weight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? colorPrimary : Colors.black)),
      ],
    );
  }

 Widget _buildBottomAction(BuildContext context, Function style, String formattedTotal, int finalPrice, NumberFormat currencyFormat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tổng cộng', style: style(size: 16, weight: FontWeight.bold)),
              Text('VND $formattedTotal', style: style(size: 20, weight: FontWeight.bold, color: colorPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                // 1. Hiển thị Loading Dialog để tránh user bấm nhiều lần
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );

                try {
                                final userRef = FirebaseFirestore.instance.collection('users').doc();
                  final String generatedUserId = userRef.id;

                  await userRef.set({
                    'firstName': firstName,
                    'lastName': lastName,
                    'email': email,
                    'phoneNumber': phone,
                    'createdAt': FieldValue.serverTimestamp(),
                    'updatedAt': FieldValue.serverTimestamp(),
                  });
                  // 2. Chuẩn bị dữ liệu theo Schema bookings của bạn
                  final bookingRef = FirebaseFirestore.instance.collection('bookings').doc();
                  final String generatedBookingId = bookingRef.id;

                  final bookingData = {
                    'userId': 'guest_user_123', // Thay bằng ID user thật nếu có hệ thống Login
                    'hotelId': hotel.id,
                    'roomTypeId': 'standard_room', // Tạm để mặc định
                    'checkinDate': dateRange?.start,
                    'checkoutDate': dateRange?.end,
                    'roomsCount': rooms,
                    'adultsCount': adults,
                    'childrenCount': children,
                    'bookingDate': FieldValue.serverTimestamp(),
                    'paymentState': 'UNPAID',
                    'paymentTiming': 'POSTPAID',
                    'bookingStatus': 'CONFIRMED',
                    'totalPrice': finalPrice,
                    'hotelSnapshot': {
                      'hotelName': hotel.hotelName,
                      'city': hotel.city,
                      'address': hotel.address,
                      'pricePerNight': hotel.pricePerNight,
                    },
                    'roomSnapshot': {
                      'roomName': 'Phòng tiêu chuẩn',
                      'maxAdults': 2,
                      'maxChildren': 1,
                    },
                    'createdAt': FieldValue.serverTimestamp(),
                    'updatedAt': FieldValue.serverTimestamp(),
                  };

                  // 3. Lưu vào Firestore
                  await bookingRef.set(bookingData);

                  // 4. Tắt loading và chuyển trang
                  if (context.mounted) {
                    Navigator.pop(context); // Tắt loading dialog

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingSuccessScreen(
                          totalPrice: "VND $formattedTotal",
                          // Lấy 6 ký tự đầu của ID làm mã phòng cho đẹp
                          bookingId: generatedBookingId.substring(0, 6).toUpperCase(),
                          bookingDate: DateFormat('dd, \'thg\' M, yyyy').format(DateTime.now()),
                          status: "Thanh toán khi trả phòng",
                          email: email,
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi khi đặt phòng: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Xác nhận đặt phòng', style: style(size: 16, weight: FontWeight.bold, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}