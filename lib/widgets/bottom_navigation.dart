import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double iconSize;
  final Color selectedColor;
  final Color unselectedColor;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.iconSize = 24,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.grey,
  });

  Color _iconColor(int index) =>
      currentIndex == index ? selectedColor : unselectedColor;

  BottomNavigationBarItem _buildItem({
    required String asset,
    required int index,
  }) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        asset,
        width: iconSize,
        height: iconSize,
        // force tint even if SVG has fills
        colorFilter: ColorFilter.mode(_iconColor(index), BlendMode.srcIn),
      ),
      label: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
      items: <BottomNavigationBarItem>[
        _buildItem(asset: 'assets/images/ic_bottom_nav_plane.svg', index: 0),
        _buildItem(asset: 'assets/images/ic_bottom_nav_search.svg', index: 1),
        _buildItem(
          asset: 'assets/images/ic_bottom_nav_notification.svg',
          index: 2,
        ),
        _buildItem(asset: 'assets/images/ic_bottom_nav_account.svg', index: 3),
      ],
    );
  }
}
