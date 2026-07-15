import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Hàm lấy luồng dữ liệu phòng theo loại
  Stream<QuerySnapshot> getRoomsByType(String type) {
    return _db
        .collection('rooms')
        .where('type', isEqualTo: type)
        .snapshots();
  }
}