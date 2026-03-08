import 'package:flutter/material.dart';
import '../config/default.dart';

class SubAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const SubAppBar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: colorPrimary,
      toolbarHeight: 80,
      title: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontFamily: fontFamilyPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
