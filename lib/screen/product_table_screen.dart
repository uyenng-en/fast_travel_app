import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../getdata/product_data.dart';
import '../models/category.dart';
import '../getdata/category_data.dart';

class ProductTableScreen extends StatefulWidget {
  const ProductTableScreen({super.key});

  @override
  State<ProductTableScreen> createState() => _ProductTableScreenState();
}

class _ProductTableScreenState extends State<ProductTableScreen> {
  final ProductData _productData = ProductData();
  final CategoryData _categoryData = CategoryData();
  List<Product> _products = [];
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final products = await _productData.getProducts();
    final categories = await _categoryData.getCategories();
    setState(() {
      _products = products;
      _categories = categories;
    });
  }

  String _getCategoryName(int id) {
    final cat = _categories.firstWhere(
      (c) => c.id == id,
      orElse: () => Category(id: 0, name: 'Không rõ', image: ''),
    );
    return cat.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bảng sản phẩm')),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(
              label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text(
                'Hình ảnh',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Tên sản phẩm',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Loại sản phẩm',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text('Giá', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
          rows:
              _products.map((product) {
                return DataRow(
                  cells: [
                    DataCell(Text(product.id.toString())),
                    DataCell(
                      Image.asset(
                        'assets/images/${product.image}',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    DataCell(
                      Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    DataCell(Text(_getCategoryName(product.categoryId))),
                    DataCell(
                      Text(
                        NumberFormat('###,###.###').format(product.price),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }
}
