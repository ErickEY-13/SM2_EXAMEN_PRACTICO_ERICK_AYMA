import 'package:cloud_firestore/cloud_firestore.dart';

class LoginHistory {
  final String userId;
  final String email;
  final DateTime timestamp;
  final String ipAddress;

  LoginHistory({
    required this.userId,
    required this.email,
    required this.timestamp,
    required this.ipAddress,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'timestamp': timestamp,
      'ipAddress': ipAddress,
    };
  }

  factory LoginHistory.fromMap(Map<String, dynamic> map) {
    return LoginHistory(
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      ipAddress: map['ipAddress'] ?? '',
    );
  }
}