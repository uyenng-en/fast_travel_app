import 'package:flutter/material.dart';
import '../config/default.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: colorPrimary,
      toolbarHeight: 100,
      title: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/images/logo_main.png", height: 32),
            const SizedBox(height: 4),
            Text(
              "Tìm nơi ở tốt nhất ở gần bạn",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontFamily: fontFamilyPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
