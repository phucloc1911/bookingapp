import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  String _id;
  String _roomId;
  String _userId;
  double _rating;
  String _comment;
  DateTime _createdAt;
  String _userName;

  Review({
    required String id,
    required String roomId,
    required String userId,
    required double rating,
    required String comment,
    required DateTime createdAt,
    String userName = 'Khách hàng',
  }) : _id = id,
       _roomId = roomId,
       _userId = userId,
       _rating = rating,
       _comment = comment,
       _createdAt = createdAt,
       _userName = userName;

  String get id => _id;
  String get roomId => _roomId;
  String get userId => _userId;
  double get rating => _rating;
  String get comment => _comment;
  DateTime get createdAt => _createdAt;
  String get userName => _userName;

  // 4. SETTER (Các phương thức kiểm soát cập nhật dữ liệu)
  set id(String value) => _id = value;
  set roomId(String value) => _roomId = value;
  set userId(String value) => _userId = value;
  set rating(double value) => _rating = value;
  set comment(String value) => _comment = value;
  set createdAt(DateTime value) => _createdAt = value;
  set userName(String value) => _userName = value;

  // 5. HÀM CHUYỂN ĐỔI DỮ LIỆU TỪ FIREBASE VỀ APP (fromMap / fromJson)[cite: 1]
  factory Review.fromMap(Map<String, dynamic> map, String documentId) {
    return Review(
      id: documentId,
      roomId: map['roomId'] ?? '',
      userId: map['userId'] ?? '',
      // Tự động quy đổi int thành double phòng lỗi type cast từ Firestore
      rating: (map['rating'] ?? 5).toDouble(),
      comment: map['comment'] ?? '',
      // Quy đổi kiểu Timestamp của Firebase về DateTime của Dart[cite: 1]
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      userName: map['userName'] ?? 'Khách hàng',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': _roomId,
      'userId': _userId,
      'rating': _rating,
      'comment': _comment,
      'createdAt': Timestamp.fromDate(_createdAt),
      'userName': _userName,
    };
  }
}
