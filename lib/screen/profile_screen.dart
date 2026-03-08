import 'package:fast_travel_app/config/default.dart';
import 'package:fast_travel_app/widgets/sub_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileScreen extends StatelessWidget {
  final double iconSize;
  const ProfileScreen({super.key, this.iconSize = 24});

  Widget _profileHeader(BuildContext context) {
    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 28,
          backgroundImage: const AssetImage('assets/images/img_avatar.jpg'),
        ),
        const SizedBox(width: 12),
        // Name + Bio
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Họ tên',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4),
            Text('Bio', style: TextStyle(fontSize: 13, color: Colors.black54)),
          ],
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _settingsTileAcc({
    required String asset,
    required String title,
    VoidCallback? onTap,
    bool dense = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
      dense: dense,
      tileColor: colorBackground,
      leading: SizedBox(
        width: 30,
        child: Center(
          child: SvgPicture.asset(
            asset,
            width: iconSize,
            height: iconSize,
            // tint the svg; if this doesn't work, edit the svg to use `currentColor`
            color: Colors.black54,
          ),
        ),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: SvgPicture.asset("assets/images/ic_acc_page_left_arrow.svg"),
      onTap: onTap,
    );
  }

  Widget _settingsTileSupport({
    required String title,
    VoidCallback? onTap,
    bool dense = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
      dense: dense,
      tileColor: colorBackground,
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: SvgPicture.asset("assets/images/ic_acc_page_left_arrow.svg"),
      onTap: onTap,
    );
  }

  Widget _supportCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: colorBackground),
      child: Column(
        children: [
          // Header inside card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Hỗ trợ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
            ),
          ),
          _settingsTileSupport(title: 'Phiếu hỗ trợ', onTap: () {}),
          _settingsTileSupport(title: 'Hỏi đáp', onTap: () {}),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SubAppBar(title: "Hồ sơ người dùng"),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _profileHeader(context),
                const SizedBox(height: 18),
                _sectionTitle('Settings'),
                const SizedBox(height: 6),
                Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _settingsTileAcc(
                        asset: "assets/images/ic_acc_page_account.svg",
                        title: 'Quản lý tài khoản',
                        onTap: () {},
                      ),
                      _settingsTileAcc(
                        asset: "assets/images/ic_acc_page_lock.svg",
                        title: 'Riêng tư & Bảo mật',
                        onTap: () {},
                      ),
                      _settingsTileAcc(
                        asset: "assets/images/ic_acc_page_camera.svg",
                        title: 'Quyền hạn',
                        onTap: () {},
                      ),
                      _settingsTileAcc(
                        asset: "assets/images/ic_acc_page_wallet.svg",
                        title: 'Số dư ví',
                        onTap: () {},
                      ),
                      _settingsTileAcc(
                        asset: "assets/images/ic_acc_page_share.svg",
                        title: 'Liên kết',
                        onTap: () {},
                      ),
                      _settingsTileAcc(
                        asset: "assets/images/ic_acc_page_qr.svg",
                        title: 'Codes',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _supportCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
