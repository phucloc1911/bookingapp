class Booking {
  String _id;
  String _userId;
  String _itemId;      // ID của khách sạn/homestay/resort
  String _itemType;    // Phân loại: 'Hotel', 'Resort', hoặc 'Homestay'
  DateTime _checkIn;
  DateTime _checkOut;
  double _totalPrice;
  String _status;      // 'Pending', 'Confirmed', 'Cancelled'

  Booking({
    required String id,
    required String userId,
    required String itemId,
    required String itemType,
    required DateTime checkIn,
    required DateTime checkOut,
    required double totalPrice,
    String status = 'Pending',
  })  : _id = id,
        _userId = userId,
        _itemId = itemId,
        _itemType = itemType,
        _checkIn = checkIn,
        _checkOut = checkOut,
        _totalPrice = totalPrice,
        _status = status;

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      itemId: json['itemId'] ?? '',
      itemType: json['itemType'] ?? 'Hotel',
      checkIn: DateTime.parse(json['checkIn']),
      checkOut: DateTime.parse(json['checkOut']),
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'Pending',
    );
  }

  // Getters
  String get id => _id;
  String get userId => _userId;
  String get itemId => _itemId;
  String get itemType => _itemType;
  DateTime get checkIn => _checkIn;
  DateTime get checkOut => _checkOut;
  double get totalPrice => _totalPrice;
  String get status => _status;

  // Setters
  set status(String value) => _status = value;

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'userId': _userId,
      'itemId': _itemId,
      'itemType': _itemType,
      'checkIn': _checkIn.toIso8601String(), // Lưu ngày dưới dạng chuỗi ISO
      'checkOut': _checkOut.toIso8601String(),
      'totalPrice': _totalPrice,
      'status': _status,
    };
  }
}