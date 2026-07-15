import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Lấy luồng dữ liệu phòng theo loại
  Stream<QuerySnapshot> getRoomsByType(String type) {
    return _db.collection('rooms').where('type', isEqualTo: type).snapshots();
  }

  // Lấy toàn bộ danh sách phòng
  Stream<QuerySnapshot> getAllRooms() {
    return _db.collection('rooms').snapshots();
  }

  // Lấy lịch sử đặt phòng của 1 User theo trạng thái
  Stream<QuerySnapshot> getUserBookings(String userId, List<String> statuses) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: statuses)
        .snapshots();
  }

  Stream<QuerySnapshot> getAllBookingsForAdmin() {
    return _db
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': newStatus,
    });
  }

  // Xóa đơn đặt phòng (Dành cho Admin)
  Future<void> deleteBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).delete();
  }

  Stream<QuerySnapshot> getRoomReviews(String roomId) {
    return _db
        .collection('reviews')
        .where('roomId', isEqualTo: roomId)
        .snapshots();
  }

  Future<void> addReview({
    required String roomId,
    required String userId,
    required String userName,
    required int rating,
    required String comment,
  }) async {
    await _db.collection('reviews').add({
      'roomId': roomId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot> checkFavorite(String roomId) async {
    return await _db.collection('favorites').doc(roomId).get();
  }

  Future<void> addFavorite(String roomId, Map<String, dynamic> roomData) async {
    await _db.collection('favorites').doc(roomId).set(roomData);
  }

  Future<void> removeFavorite(String roomId) async {
    await _db.collection('favorites').doc(roomId).delete();
  }
}
