import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔐 reference ไปที่ scans ของ user ปัจจุบัน
  CollectionReference<Map<String, dynamic>> get _scanRef {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return _db
        .collection('users')
        .doc(user.uid)
        .collection('scans');
  }

  /// ➕ เพิ่มผลการ Scan
  Future<void> addScan(String result) async {
    await _scanRef.add({
      'result': result,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// 📜 ดึงประวัติ Scan (ใช้กับ History)
  Stream<QuerySnapshot<Map<String, dynamic>>> getScans() {
    return _scanRef
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// ❌ ลบ Scan
  Future<void> deleteScan(String docId) async {
    await _scanRef.doc(docId).delete();
  }

  /// 📊 ดึงข้อมูลครั้งเดียว (ใช้กับ Dashboard)
  Future<QuerySnapshot<Map<String, dynamic>>> getScansOnce() async {
    return await _scanRef.get();
  }
}
