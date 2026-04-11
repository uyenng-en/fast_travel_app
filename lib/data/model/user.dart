import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String? firstName;
  final String? lastName;
  final String email;
  final String phoneNumber;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppUser.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;
    return AppUser(
      id: doc.id,
      firstName: data['firstName'],
      lastName: data['lastName'],
      email: data['email'],
      phoneNumber: data['phoneNumber'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phoneNumber': phoneNumber,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}