class Room {
  String _id;
  String _title;
  String _type;
  double _rating;
  double _price;
  String _imageUrl;
  List<String> _amenities;
  bool _isFavorite;
  String _description;
  List<String> _gallery;
  double _price2Beds;
  double _price3Beds;
  Room({
    required String id,
    required String title,
    required String type,
    required double rating,
    required double price,
    required String imageUrl,
    required List<String> amenities,
    bool isFavorite = false,
    required String description,
    required List<String> gallery,
    required double price2Beds,
    required double price3Beds,
  }) : _id = id,
       _title = title,
       _type = type,
       _rating = rating,
       _price = price,
       _imageUrl = imageUrl,
       _amenities = amenities,
       _isFavorite = isFavorite,
       _description = description,
       _gallery = gallery,
       _price2Beds = price2Beds,
       _price3Beds = price3Beds;

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Phòng chưa có tên',
      type: json['type'] ?? 'Khách sạn',
      rating: (json['rating'] ?? 0.0).toDouble(),
      price: (json['price'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'])
          : [],
      isFavorite: json['isFavorite'] ?? false,
      description: json['description'] ?? 'Chưa có mô tả cho phòng này.',
      gallery: json['gallery'] != null
          ? List<String>.from(json['gallery'])
          : [],
      price2Beds: (json['price2Beds'] ?? (json['price'] ?? 0.0))
          .toDouble(), // Mặc định bằng giá 1 giường nếu trống
      price3Beds: (json['price3Beds'] ?? (json['price'] ?? 0.0)).toDouble(),
    );
  }

  // GETTERS & SETTERS
  String get id => _id;
  String get title => _title;
  String get type => _type;
  double get rating => _rating;
  double get price => _price;
  String get imageUrl => _imageUrl;
  List<String> get amenities => _amenities;
  bool get isFavorite => _isFavorite;
  String get description => _description;
  List<String> get gallery => _gallery;
  double get price2Beds => _price2Beds;
  double get price3Beds => _price3Beds;
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

  set description(String value) {
    _description = value;
  }

  set gallery(List<String> value) {
    _gallery = value;
  }

  set price2Beds(double value) {
    _price2Beds = value;
  }

  set price3Beds(double value) {
    _price3Beds = value;
  }

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
      'description': _description,
      'gallery': _gallery,
      'price2Beds': _price2Beds,
      'price3Beds': _price3Beds,
    };
  }
}
