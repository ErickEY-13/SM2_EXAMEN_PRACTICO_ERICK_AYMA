import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../domain/login_history.dart';

class LoginHistoryRepository {
  final FirebaseFirestore _firestore;

  LoginHistoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> getPublicIp() async {
    try {
      final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ip'];
      }
      return 'Unknown IP';
    } catch (e) {
      return 'Unknown IP';
    }
  }

  Future<void> recordLogin(String userId, String email) async {
    final ipAddress = await getPublicIp();
    final loginHistory = LoginHistory(
      userId: userId,
      email: email,
      timestamp: DateTime.now(),
      ipAddress: ipAddress,
    );

    await _firestore
        .collection('login_history')
        .add(loginHistory.toMap());
  }

  Stream<List<LoginHistory>> getLoginHistory(String userId) {
    return _firestore
        .collection('login_history')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => LoginHistory.fromMap(doc.data()))
              .toList();
        });
  }
}