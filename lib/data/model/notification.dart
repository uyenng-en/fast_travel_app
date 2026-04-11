import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String title;
  final String content;
  final Timestamp notificationAt;
  final bool isRead;
  final Timestamp createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.notificationAt,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;
    return AppNotification(
      id: doc.id,
      title: data['title'],
      content: data['content'],
      notificationAt: data['notificationAt'],
      isRead: data['isRead'],
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'content': content,
    'notificationAt': notificationAt,
    'isRead': isRead,
    'createdAt': createdAt,
  };
}