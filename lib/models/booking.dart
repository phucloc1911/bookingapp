import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  String id;
  String userId;
  String itemId;
  String itemTitle; // Thêm tên phòng để mốt hiện lịch sử cho dễ
  String itemType;
  DateTime checkIn;
  DateTime checkOut;
  double totalPrice;
  String status;
  String? imageUrl; // Thêm ảnh

  Booking({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.itemTitle,
    required this.itemType,
    required this.checkIn,
    required this.checkOut,
    required this.totalPrice,
    this.status = 'Pending',
    this.imageUrl,
  });

  // HÀM QUAN TRỌNG: Đóng gói toàn bộ object thành Map để ném lên Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'itemId': itemId,
      'itemTitle': itemTitle,
      'itemType': itemType,
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut.toIso8601String(),
      'totalPrice': totalPrice,
      'status': status,
      'imageUrl': imageUrl ?? '', // Nếu null thì gán chuỗi rỗng
      'createdAt': FieldValue.serverTimestamp(), // Tự động lấy giờ hệ thống
    };
  }
}
