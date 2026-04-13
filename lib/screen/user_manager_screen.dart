import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_travel_app/data/model/user.dart';
import 'package:fast_travel_app/data/model/notification.dart';
import 'package:flutter/material.dart';

class UserManagerScreen extends StatefulWidget {
  const UserManagerScreen({super.key});

  @override
  State<UserManagerScreen> createState() => _UserManagerScreenState();
}

class _UserManagerScreenState extends State<UserManagerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showUserDialog([AppUser? user]) {
    final isEditing = user != null;
    final firstNameController = TextEditingController(text: user?.firstName ?? '');
    final lastNameController = TextEditingController(text: user?.lastName ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final passwordController = TextEditingController(text: user?.password ?? '');
    final phoneController = TextEditingController(text: user?.phoneNumber ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Update User' : 'Add User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'firstName': firstNameController.text,
                'lastName': lastNameController.text,
                'email': emailController.text,
                'password': passwordController.text,
                'phoneNumber': phoneController.text,
                'updatedAt': FieldValue.serverTimestamp(),
              };

              if (isEditing) {
                await _firestore.collection('users').doc(user.id).update(data);
              } else {
                data['createdAt'] = FieldValue.serverTimestamp();
                await _firestore.collection('users').add(data);
              }

              if (mounted) Navigator.pop(context);
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _showNotificationDialog(String userId, [AppNotification? notification]) {
    final isEditing = notification != null;
    final titleController = TextEditingController(text: notification?.title ?? '');
    final contentController = TextEditingController(text: notification?.content ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Update Notification' : 'Send Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'title': titleController.text,
                'content': contentController.text,
                'notificationAt': FieldValue.serverTimestamp(),
                'isRead': isEditing ? notification.isRead : false,
                'createdAt': isEditing ? notification.createdAt : FieldValue.serverTimestamp(),
              };

              final notifRef = _firestore
                  .collection('users')
                  .doc(userId)
                  .collection('notifications');

              if (isEditing) {
                await notifRef.doc(notification.id).update(data);
              } else {
                await notifRef.add(data);
              }

              if (mounted) Navigator.pop(context);
            },
            child: Text(isEditing ? 'Update' : 'Send'),
          ),
        ],
      ),
    );
  }

  void _manageNotifications(AppUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Notifications: ${user.firstName}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.add_alert, color: Colors.blue),
                    onPressed: () => _showNotificationDialog(user.id),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(user.id)
                    .collection('notifications')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final notif = AppNotification.fromFirestore(
                          docs[index] as DocumentSnapshot<Map<String, dynamic>>);
                      return ListTile(
                        title: Text(notif.title),
                        subtitle: Text(notif.content),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _showNotificationDialog(user.id, notif),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                              onPressed: () => _firestore
                                  .collection('users')
                                  .doc(user.id)
                                  .collection('notifications')
                                  .doc(notif.id)
                                  .delete(),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Manager')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = AppUser.fromFirestore(
                  users[index] as DocumentSnapshot<Map<String, dynamic>>);
              return ListTile(
                title: Text('${user.firstName} ${user.lastName}'),
                subtitle: Text(user.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications, color: Colors.orange),
                      onPressed: () => _manageNotifications(user),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showUserDialog(user),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _firestore.collection('users').doc(user.id).delete(),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(),
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
