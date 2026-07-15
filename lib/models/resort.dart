import 'room.dart';

class Resort {
  String _id;
  String _name;
  String _address;
  String _description;
  double _starRating; // Resort thường chú trọng số sao hơn khách sạn thông thường
  List<Room> _rooms;

  Resort({
    required String id,
    required String name,
    required String address,
    required String description,
    required double starRating,
    required List<Room> rooms,
  })  : _id = id,
        _name = name,
        _address = address,
        _description = description,
        _starRating = starRating,
        _rooms = rooms;

  factory Resort.fromJson(Map<String, dynamic> json) {
    var roomList = (json['rooms'] as List<dynamic>?)
        ?.map((roomJson) => Room.fromJson(roomJson))
        .toList() ?? [];

    return Resort(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      description: json['description'] ?? '',
      starRating: (json['starRating'] ?? 0.0).toDouble(),
      rooms: roomList,
    );
  }

  // Getters
  String get id => _id;
  String get name => _name;
  String get address => _address;
  String get description => _description;
  double get starRating => _starRating;
  List<Room> get rooms => _rooms;

  // Setters
  set id(String value) => _id = value;
  set name(String value) => _name = value;
  set address(String value) => _address = value;
  set description(String value) => _description = value;
  set starRating(double value) => _starRating = value;
  set rooms(List<Room> value) => _rooms = value;

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'name': _name,
      'address': _address,
      'description': _description,
      'starRating': _starRating,
      'rooms': _rooms.map((room) => room.toJson()).toList(),
    };
  }
}