import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/default.dart';
import 'package:fast_travel_app/widgets/main_app_bar.dart';
import '../data/model/hotel.dart';
import 'search_hotel_screen.dart';
import 'select_location_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  DateTimeRange? selectedDateRange;
  String destination = "Đà Lạt";
  String guests = "1 phòng - 2 người lớn - 0 trẻ em";
  String? lastSearchDestination;
  String? lastSearchInfo;

  @override
  void initState() {
    super.initState();
    _loadSearchData();
  }

  Future<void> _loadSearchData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      destination = prefs.getString('destination') ?? "Đà Lạt";
      guests = prefs.getString('guests') ?? "1 phòng - 2 người lớn - 0 trẻ em";
      
      final startStr = prefs.getString('startDate');
      final endStr = prefs.getString('endDate');
      if (startStr != null && endStr != null) {
        selectedDateRange = DateTimeRange(
          start: DateTime.parse(startStr),
          end: DateTime.parse(endStr),
        );
      }

      lastSearchDestination = prefs.getString('lastDestination');
      lastSearchInfo = prefs.getString('lastInfo');
    });
  }

  Future<void> _saveSearchData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('destination', destination);
    await prefs.setString('guests', guests);
    if (selectedDateRange != null) {
      await prefs.setString('startDate', selectedDateRange!.start.toIso8601String());
      await prefs.setString('endDate', selectedDateRange!.end.toIso8601String());
    }

    // Save as "Recent Search"
    await prefs.setString('lastDestination', destination);
    String info = "";
    if (selectedDateRange != null) {
      info = "${selectedDateRange!.start.day}/${selectedDateRange!.start.month} - ${selectedDateRange!.end.day}/${selectedDateRange!.end.month}, ";
    }
    info += guests.split('-')[1].trim(); // Extracting "2 người lớn" part roughly
    await prefs.setString('lastInfo', info);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: selectedDateRange ?? DateTimeRange(start: DateTime.now(), end: DateTime.now().add(const Duration(days: 2))),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      helpText: 'Chọn ngày nhận và trả phòng',
      saveText: 'Xác nhận',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2B5296),
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
                  if (lastSearchDestination != null) ...[
                    _buildSectionTitle("Tiếp tục tìm kiếm của bạn"),
                    const SizedBox(height: 12),
                    _buildRecentSearchCard(),
                    const SizedBox(height: 24),
                  ],
                  _buildPromoBanner(),
                  const SizedBox(height: 12),
                  _buildHotelGrid(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    const double extraBlueHeight = 40.0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            const MainAppBar(),
            Container(
              height: extraBlueHeight,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF2B5296),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 120, left: 16, right: 16),
          child: Column(
            children: [
              _buildSearchCard(
                child: InkWell(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SelectLocationScreen(),
                      ),
                    );
                    if (result != null && result is String) {
                      setState(() {
                        destination = result;
                      });
                    }
                  },
                  child: _buildSearchInput(Icons.location_on, destination,
                      showTarget: true),
                ),
              ),
              const SizedBox(height: 8),
              _buildSearchCard(
                child: InkWell(
                  onTap: () => _selectDate(context),
                  child: _buildSearchInput(
                      Icons.calendar_today,
                      selectedDateRange == null
                          ? "Th 3, 24 thg 2"
                          : "Th ${selectedDateRange!.start.weekday}, ${selectedDateRange!.start.day} thg ${selectedDateRange!.start.month}"),
                ),
              ),
              const SizedBox(height: 8),
              _buildSearchCard(
                child: InkWell(
                  onTap: () => _selectDate(context),
                  child: _buildSearchInput(
                      Icons.calendar_today,
                      selectedDateRange == null
                          ? "Th 5, 26 thg 2"
                          : "Th ${selectedDateRange!.end.weekday}, ${selectedDateRange!.end.day} thg ${selectedDateRange!.end.month}"),
                ),
              ),
              const SizedBox(height: 8),
              _buildSearchCard(
                child: _buildSearchInput(
                    Icons.person, guests,
                    showArrow: true),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () async {
                    await _saveSearchData();
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchHotelScreen(
                          destination: destination,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    elevation: 2,
                  ),
                  child: const Text("Tìm kiếm",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: child,
    );
  }

  Widget _buildSearchInput(IconData icon, String text,
      {bool showTarget = false, bool showArrow = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[900], size: 20),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 15, color: Colors.black87))),
          if (showTarget)
            Icon(Icons.gps_fixed, color: Colors.blue[900], size: 20),
          if (showArrow)
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSuggestionList() {
    List<Map<String, String>> cities = [
      {"name": "TP. Hồ Chí Minh", "img": "assets/images/cities/hcmc.jpg"},
      {"name": "Vũng Tàu", "img": "assets/images/cities/vungtau.jpg"},
      {"name": "Đà Lạt", "img": "assets/images/cities/dalat.jpg"},
      {"name": "Hà Nội", "img": "assets/images/cities/hanoi.jpg"},
      {"name": "Đà Nẵng", "img": "assets/images/cities/danang.jpg"},
    ];
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cities.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                destination = cities[index]['name']!;
              });
            },
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(cities[index]['img']!),
                  fit: BoxFit.cover,
                ),
              ),
              alignment: Alignment.bottomLeft,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(8)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  ),
                ),
                child: Text(cities[index]['name']!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentSearchCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black12.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              "assets/images/cities/dalat.jpg",
              width: 70,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  lastSearchDestination ?? "Đà Lạt",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  lastSearchInfo ?? "3 - 4 thg 3, 2 người lớn",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage("assets/images/cities/vungtau.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.4), Colors.transparent],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Ưu đãi cho Vũng Tàu",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
              child: const Text("Khám phá ngay",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHotelGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('hotels').limit(4).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final hotels = snapshot.data?.docs ?? [];

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.45,
          children: hotels.map((doc) {
            final hotel = Hotel.fromFirestore(
                doc as DocumentSnapshot<Map<String, dynamic>>);
            return _buildHotelCardFromModel(hotel);
          }).toList(),
        );
      },
    );
  }

  Widget _buildHotelCardFromModel(Hotel hotel) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('hotels')
          .doc(hotel.id)
          .collection('images')
          .orderBy('sortOrder')
          .limit(1)
          .get(),
      builder: (context, imgSnapshot) {
        String? imagePath;
        if (imgSnapshot.hasData && imgSnapshot.data!.docs.isNotEmpty) {
          imagePath = imgSnapshot.data!.docs.first.get('imagePath');
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('reviews')
              .where('hotelId', isEqualTo: hotel.id)
              .snapshots(),
          builder: (context, revSnapshot) {
            double avgRating = 0;
            int reviewCount = 0;

            if (revSnapshot.hasData && revSnapshot.data!.docs.isNotEmpty) {
              reviewCount = revSnapshot.data!.docs.length;
              double totalRating = 0;
              for (var doc in revSnapshot.data!.docs) {
                totalRating += (doc.get('rating') as num).toDouble();
              }
              avgRating = totalRating / reviewCount;
            }

            final String formattedPrice = hotel.pricePerNight
                .toString()
                .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]}.');

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(4)),
                    child: imagePath != null
                        ? Image.asset(
                            "assets/images/hotels/$imagePath",
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                    height: 160,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.hotel,
                                        size: 50, color: Colors.grey)),
                          )
                        : Container(
                            height: 160,
                            color: Colors.grey[200],
                            child: const Icon(Icons.hotel,
                                size: 50, color: Colors.grey)),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hotel.hotelName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2B5296),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  avgRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "${_getRatingText(avgRating)} • $reviewCount đánh giá",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black87),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 16, color: Colors.black87),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(hotel.city,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black87),
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green[800],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "Cách trung tâm 3,5km",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green[800],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "Hủy miễn phí",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "$formattedPrice VND",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                const Text(
                                  "Đã bao gồm thuế và phí",
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getRatingText(double rating) {
    if (rating >= 9.0) return 'Xuất sắc';
    if (rating >= 8.0) return 'Rất tốt';
    if (rating >= 7.0) return 'Tốt';
    if (rating >= 5.0) return 'Trung bình';
    if (rating >= 3.0) return 'Tệ';
    return 'Rất tệ';
  }
}
