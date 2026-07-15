import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  String _id;
  String _userId;
  String _itemId;
  String _itemTitle;
  String _itemType;
  DateTime _checkIn;
  DateTime _checkOut;
  double _totalPrice;
  String _status;
  String? _imageUrl;

  // CONSTRUCTOR
  Booking({
    required String id,
    required String userId,
    required String itemId,
    required String itemTitle,
    required String itemType,
    required DateTime checkIn,
    required DateTime checkOut,
    required double totalPrice,
    String status = 'Pending',
    String? imageUrl,
  }) : _id = id,
       _userId = userId,
       _itemId = itemId,
       _itemTitle = itemTitle,
       _itemType = itemType,
       _checkIn = checkIn,
       _checkOut = checkOut,
       _totalPrice = totalPrice,
       _status = status,
       _imageUrl = imageUrl;

  // 3. GETTER
  String get id => _id;
  String get userId => _userId;
  String get itemId => _itemId;
  String get itemTitle => _itemTitle;
  String get itemType => _itemType;
  DateTime get checkIn => _checkIn;
  DateTime get checkOut => _checkOut;
  double get totalPrice => _totalPrice;
  String get status => _status;
  String? get imageUrl => _imageUrl;

  // 4. SETTER
  set id(String value) => _id = value;
  set userId(String value) => _userId = value;
  set itemId(String value) => _itemId = value;
  set itemTitle(String value) => _itemTitle = value;
  set itemType(String value) => _itemType = value;
  set checkIn(DateTime value) => _checkIn = value;
  set checkOut(DateTime value) => _checkOut = value;
  set totalPrice(double value) => _totalPrice = value;
  set status(String value) => _status = value;
  set imageUrl(String? value) => _imageUrl = value;

  //  Chuyển dữ liệu từ Firebase Firestore về Object Booking
  factory Booking.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parseDate(dynamic dateData) {
      if (dateData == null) return DateTime.now();
      if (dateData is Timestamp) return dateData.toDate();
      if (dateData is String)
        return DateTime.tryParse(dateData) ?? DateTime.now();
      return DateTime.now();
    }

    return Booking(
      id: documentId,
      userId: map['userId'] ?? '',
      itemId: map['itemId'] ?? '',
      itemTitle: map['itemTitle'] ?? 'Phòng chưa có tên',
      itemType: map['itemType'] ?? 'Khách sạn',
      checkIn: parseDate(map['checkIn']),
      checkOut: parseDate(map['checkOut']),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      status: map['status'] ?? 'Pending',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  // Đóng gói Object thành Map để đẩy lên Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'userId': _userId,
      'itemId': _itemId,
      'itemTitle': _itemTitle,
      'itemType': _itemType,
      'checkIn': _checkIn.toIso8601String(),
      'checkOut': _checkOut.toIso8601String(),
      'totalPrice': _totalPrice,
      'status': _status,
      'imageUrl': _imageUrl ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
