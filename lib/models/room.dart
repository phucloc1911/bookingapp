class Room {
  // 1. Khai báo các thuộc tính Private (Chỉ dùng trong nội bộ class này)
  String _id;
  String _title;
  String _type;
  double _rating;
  double _price;
  String _imageUrl;
  List<String> _amenities;
  bool _isFavorite;

  // 2. Hàm khởi tạo (Constructor) nhận biến Public và gán vào Private
  Room({
    required String id,
    required String title,
    required String type,
    required double rating,
    required double price,
    required String imageUrl,
    required List<String> amenities,
    bool isFavorite = false,
  })  : _id = id,
        _title = title,
        _type = type,
        _rating = rating,
        _price = price,
        _imageUrl = imageUrl,
        _amenities = amenities,
        _isFavorite = isFavorite;

  // 3. Hàm từ điển: Đổ dữ liệu JSON từ Firebase về App
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Phòng chưa có tên',
      type: json['type'] ?? 'Khách sạn',
      rating: (json['rating'] ?? 0.0).toDouble(),
      price: (json['price'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      amenities: json['amenities'] != null ? List<String>.from(json['amenities']) : [],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  // 4. GETTERS: Cho phép các màn hình khác đọc dữ liệu
  String get id => _id;
  String get title => _title;
  String get type => _type;
  double get rating => _rating;
  double get price => _price;
  String get imageUrl => _imageUrl;
  List<String> get amenities => _amenities;
  bool get isFavorite => _isFavorite;

  // 5. SETTERS: Cho phép các màn hình khác thay đổi/cập nhật dữ liệu
  set id(String value) {
    _id = value;
  }
  set title(String value) {
    _title = value;
  }
  set type(String value) {
    _type = value;
  }
  set rating(double value) {
    _rating = value;
  }
  set price(double value) {
    // Có thể thêm logic kiểm tra giá trị ở đây (VD: if (value > 0) ...)
    _price = value;
  }
  set imageUrl(String value) {
    _imageUrl = value;
  }
  set amenities(List<String> value) {
    _amenities = value;
  }
  set isFavorite(bool value) {
    _isFavorite = value;
  }

  // 6. Hàm từ điển: Đóng gói đối tượng thành JSON để đẩy lên Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'title': _title,
      'type': _type,
      'rating': _rating,
      'price': _price,
      'imageUrl': _imageUrl,
      'amenities': _amenities,
      'isFavorite': _isFavorite,
    };
  }
}