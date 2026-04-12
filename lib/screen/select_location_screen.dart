import 'package:flutter/material.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> _allLocations = [
    'Hồ Chí Minh',
    'Hồ Tràm',
    'Hà Nội',
    'Đà Lạt',
    'Vũng Tàu',
    'Đà Nẵng',
    'Nha Trang',
    'Phú Quốc',
    'Hội An',
    'Huế',
  ];

  List<String> _filteredLocations = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredLocations = [];
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _isSearching = false;
        _filteredLocations = [];
      } else {
        _isSearching = true;
        _filteredLocations = _allLocations
            .where((location) =>
                location.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Nhập điểm đến',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 18),
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      Navigator.pop(context, value);
                    }
                  },
                ),
              ),
            ),
            Expanded(
              child: _isSearching ? _buildSearchResults() : _buildDefaultView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultView() {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.lightBlue[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.my_location, color: Colors.blue[900]),
      ),
      title: Text(
        'Xung quanh vị trí hiện tại',
        style: TextStyle(
          color: Colors.blue[900],
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: const Text(
        'Hồ Chí Minh',
        style: TextStyle(color: Colors.grey, fontSize: 14),
      ),
      onTap: () {
        Navigator.pop(context, 'Hồ Chí Minh');
      },
    );
  }

  Widget _buildSearchResults() {
    if (_filteredLocations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Không tìm thấy kết quả nào', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      itemCount: _filteredLocations.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.lightBlue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.location_on, color: Colors.blue[900]),
          ),
          title: Text(
            _filteredLocations[index],
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
          onTap: () {
            Navigator.pop(context, _filteredLocations[index]);
          },
        );
      },
    );
  }
}
