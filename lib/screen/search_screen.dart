import 'package:flutter/material.dart';
import '../config/default.dart';
import 'package:fast_travel_app/widgets/main_app_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

DateTimeRange? selectedDateRange;
Future<void> _selectDate(BuildContext context) async {
  final DateTimeRange? picked = await showDateRangePicker(
    context: context,
    initialDateRange: selectedDateRange,
    firstDate: DateTime.now(), // Không cho chọn ngày trong quá khứ
    lastDate: DateTime(2030),
    helpText: 'Chọn ngày nhận và trả phòng',
    saveText: 'Xác nhận',
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2B5296), // Màu chủ đạo của bạn
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null && picked != selectedDateRange) {
    setState(() {
      selectedDateRange = picked;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            _buildHeader(),
            
            Padding(
              
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Bạn cần gợi ý?"),
                  const SizedBox(height: 12),
                  _buildSuggestionList(),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Tiếp tục tìm kiếm của bạn"),
                  const SizedBox(height: 12),
                  _buildRecentSearchCard(),
                  const SizedBox(height: 24),
                  _buildPromoBanner(),
                  const SizedBox(height: 24),
                  _buildHotelGrid(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. Header màu xanh với Form tìm kiếm
 Widget _buildHeader() {
  // 1. Định nghĩa chiều cao phần muốn kéo dài thêm
  const double extraBlueHeight = 50.0; 

  return Stack(
    clipBehavior: Clip.none,
    children: [
      // LỚP 1: Phần kéo dài màu xanh (Nằm dưới cùng)
      // Nó sẽ nối tiếp ngay sau MainAppBar
      Column(
        children: [
          const MainAppBar(), // Thanh logo chính của bạn (giữ nguyên)
          Container(
            height: extraBlueHeight, // Chiều dài muốn kéo thêm xuống
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF2B5296), // Dùng colorPrimary của bạn
             
            ),
          ),
        ],
      ),

      // LỚP 2: Phần Form tìm kiếm đè lên
      Padding(
        // top: 133 + 20 hoặc tùy chỉnh để nó nằm đè lên phần xanh mới nối thêm
        padding: const EdgeInsets.only(top: 130, left: 16, right: 16),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12, 
                blurRadius: 10, 
                offset: Offset(0, 5)
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSearchInput(Icons.location_on, "Đà Lạt", showTarget: true),
              const Divider(),
              // Thay đổi phần ngày tháng trong Column của _buildHeader:
              InkWell(
                onTap: () => _selectDate(context),
                child: _buildSearchInput(
                  Icons.calendar_today, 
                  selectedDateRange == null 
                      ? "Th 3, 24 thg 2" 
                      : "Th ${selectedDateRange!.start.weekday}, ${selectedDateRange!.start.day} thg ${selectedDateRange!.start.month}"
                ),
              ),
              const Divider(),
              InkWell(
                onTap: () => _selectDate(context),
                child: _buildSearchInput(
                  Icons.calendar_today, 
                  selectedDateRange == null 
                      ? "Th 5, 26 thg 2" 
                      : "Th ${selectedDateRange!.end.weekday}, ${selectedDateRange!.end.day} thg ${selectedDateRange!.end.month}"
                ),
              ),
                            const Divider(),

              _buildSearchInput(Icons.person, "1 phòng - 2 người lớn - 0 trẻ em", showArrow: true),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Tìm kiếm", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    ],
  );
}

  Widget _buildSearchInput(IconData icon, String text, {bool showTarget = false, bool showArrow = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[900], size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
          if (showTarget) Icon(Icons.my_location, color: Colors.blue[900], size: 20),
          if (showArrow) const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        ],
      ),
    );
  }

  // 2. Tiêu đề các mục
  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  // 3. Danh sách gợi ý (ngang)
  Widget _buildSuggestionList() {
    List<Map<String, String>> cities = [
      {"name": "TP.Hồ Chí Minh", "img": "https://placeholder.com/150"},
      {"name": "Vũng Tàu", "img": "https://placeholder.com/150"},
      {"name": "Đà Lạt", "img": "https://placeholder.com/150"},
    ];
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cities.length,
        itemBuilder: (context, index) {
          return Container(
            width: 130,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: NetworkImage("https://picsum.photos/200/300"), // Thay bằng link thật
                fit: BoxFit.cover,
              ),
            ),
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(8),
            child: Text(cities[index]['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          );
        },
      ),
    );
  }

  // 4. Thẻ tìm kiếm gần đây
  Widget _buildRecentSearchCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, // Phải có nền màu (thường là trắng) để thấy bóng đổ
        borderRadius: BorderRadius.circular(12),
        // Thay thế border bằng boxShadow ở đây
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Màu bóng (đen mờ)
            blurRadius: 10, // Độ nhòe của bóng (càng lớn càng mờ)
            spreadRadius: 1, // Độ lan của bóng
            offset: const Offset(0, 4), // Vị trí bóng (xuống dưới 4px)
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              "https://picsum.photos/50",
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Đà Lạt",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 4), // Thêm chút khoảng cách giữa 2 dòng text
              Text(
                "3 - 4 thg 3, 2 người lớn",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          )
        ],
      ),
    );
  }
  // 5. Banner khuyến mãi
  Widget _buildPromoBanner() {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
         boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Màu bóng (đen mờ)
            blurRadius: 10, // Độ nhòe của bóng (càng lớn càng mờ)
            spreadRadius: 1, // Độ lan của bóng
            offset: const Offset(0, 4), // Vị trí bóng (xuống dưới 4px)
          ),
        ],
        image: const DecorationImage(
          image: NetworkImage("https://picsum.photos/400/100"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.black26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Ưu đãi cho Vũng Tàu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 255, 255, 255)),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
              ),
              child: const Text("Khám phá ngay", style: TextStyle(fontSize: 12,color: Colors.black)),
            )
          ],
        ),
      ),
    );
  }

  // 6. Grid khách sạn
  Widget _buildHotelGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.75,
      children: [
        _buildHotelCard("Greenland Hotel Ninh Bình", "TP. Ninh Bình", 8.5, 120, 720000),
        _buildHotelCard("Sao Mai Hotel Đà Nẵng", "TP. Ninh Bình", 9.5, 80, 500000),

      ],
    );
  }

Widget _buildHotelCard(String name, String loc, double rate, int rev, int price) {
  final String formattedPrice = price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

  return Container(
    // Giữ nguyên các thuộc tính trang trí
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Hình ảnh
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Image.network(
            "https://picsum.photos/seed/$name/300/200",
            height: 110,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        
        // 2. Nội dung text (Dùng Expanded để Spacer bên trong có tác dụng)
        Expanded( 
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B5296),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        rate.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Rất tốt • $rev đánh giá",
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Colors.grey),
                    const SizedBox(width: 2),
                    Text(loc, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),

                // CHIÊU THỨC Ở ĐÂY: Spacer sẽ đẩy mọi thứ bên dưới nó xuống đáy Container
                const Spacer(), 

                // Giá tiền luôn nằm sát góc dưới bên phải
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "$formattedPrice VND",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
}