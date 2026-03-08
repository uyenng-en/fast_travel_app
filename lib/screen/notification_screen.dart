import 'package:fast_travel_app/widgets/notification_card.dart';
import 'package:fast_travel_app/widgets/sub_app_bar.dart';
import 'package:flutter/material.dart';
import '../config/default.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //Notif off
    return Scaffold(
      appBar: const SubAppBar(title: "Thông báo"),
      body: Container(
        color: colorBackground,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 64),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/img_no_notifications.png",
                  width: 300,
                  height: 300,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );

    //Notif on
    // return Scaffold(
    //   appBar: const SubAppBar(title: "Thông báo"),
    //   body: Container(
    //     color: colorBackground,
    //     child: Center(
    //       child: Padding(
    //         padding: const EdgeInsets.fromLTRB(16, 16, 16, 64),
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.start,
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             NotificationCard(
    //               title: "Phiếu giảm giá 10% cho người dùng mới",
    //               description:
    //                   "Giảm đến 75,000 cho lần đặt vé máy bay đầu tiên và nhiều phần quà giá trị khác. Hãy nhanh tay chốt ngay!",
    //               time: "22:03",
    //               date: "01-02-2026",
    //               onTap: () {
    //                 print("Notification clicked");
    //               },
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
