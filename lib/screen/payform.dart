import 'package:fast_travel_app/config/default.dart';
import 'package:fast_travel_app/screen/paycheck.dart';
import 'package:fast_travel_app/data/model/hotel.dart'; 
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingFormPage extends StatefulWidget {
  final Hotel hotel;
  final DateTimeRange? dateRange;
  final int rooms;
  final int adults;
  final int children;

  const BookingFormPage({
    super.key,
    required this.hotel,
    this.dateRange,
    this.rooms = 1,
    this.adults = 2,
    this.children = 0,
  });

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  bool _saveInfo = false;

  // 1. TẠO KHÓA CHO FORM ĐỂ QUẢN LÝ VALIDATE
  final _formKey = GlobalKey<FormState>();

  // CÁC CONTROLLER ĐỂ LẤY DỮ LIỆU NGƯỜI DÙNG NHẬP
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat("#,###", "vi_VN");
    
    // Tính tổng số đêm và tổng tiền
    int totalDays = widget.dateRange != null ? widget.dateRange!.end.difference(widget.dateRange!.start).inDays : 1;
    if (totalDays <= 0) totalDays = 1; // Ít nhất là 1 đêm
    int totalPrice = widget.hotel.pricePerNight * totalDays * widget.rooms;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: colorPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Điền thông tin của bạn',
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            fontFamily: fontFamilyPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              // 2. BỌC TOÀN BỘ CÁC Ô NHẬP TRONG MỘT WIDGET "FORM"
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField("Tên", "Nhập tên...", _firstNameController),
                    _buildInputField("Họ", "Nhập họ...", _lastNameController),
                    // Thêm keyboardType để tối ưu UX (hiện bàn phím email/số)
                    _buildInputField("Địa chỉ email", "Nhập email...", _emailController, keyboardType: TextInputType.emailAddress),
                    _buildInputField("Điện thoại", "Nhập số điện thoại...", _phoneController, keyboardType: TextInputType.phone),
                    
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Lưu thông tin của bạn cho các đặt phòng tương lai",
                            style: TextStyle(
                              color: Colors.grey, 
                              fontSize: 14,
                              fontFamily: fontFamilyPrimary,
                            ),
                          ),
                        ),
                        Checkbox(
                          activeColor: colorPrimary,
                          value: _saveInfo,
                          onChanged: (value) {
                            setState(() {
                              _saveInfo = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${currencyFormat.format(totalPrice)} VND", 
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontFamilyPrimary,
                          ),
                        ),
                        Text(
                          "Đã bao gồm thuế và phí",
                          style: TextStyle(
                            color: Colors.grey, 
                            fontSize: 12,
                            fontFamily: fontFamilyPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // 3. KIỂM TRA ĐÃ NHẬP ĐỦ CHƯA TRƯỚC KHI CHUYỂN TRANG
                      if (_formKey.currentState!.validate()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Paycheck(
                              hotel: widget.hotel,
                              dateRange: widget.dateRange,
                              rooms: widget.rooms,
                              adults: widget.adults,
                              children: widget.children,
                              firstName: _firstNameController.text.trim(),
                              lastName: _lastNameController.text.trim(),
                              email: _emailController.text.trim(),
                              phone: _phoneController.text.trim(),
                              totalPrice: totalPrice,
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Tiếp tục",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamilyPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. ĐỔI THÀNH TEXTFORMFIELD ĐỂ CÓ THỂ VALIDATE
  Widget _buildInputField(String label, String hint, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: fontFamilyPrimary, 
                  fontWeight: FontWeight.w500),
              children: const [
                TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(fontFamily: fontFamilyPrimary), 
            // RULE VALIDATE Ở ĐÂY:
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập $label'; // Hiện lỗi nếu để trống
              }
              // Có thể thêm rule check độ dài số điện thoại hoặc format email ở đây nếu thích
              return null;
            },
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey,
                fontFamily: fontFamilyPrimary, 
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorPrimary),
              ),
              // Thêm viền đỏ khi bị lỗi validate
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}