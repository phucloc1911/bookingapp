import 'room.dart'; // Import class Room đã tạo trước đó

class Hotel {
  String _id;
  String _name;
  String _address;
  String _description;
  List<Room> _rooms; // Một khách sạn chứa danh sách nhiều phòng

  Hotel({
    required String id,
    required String name,
    required String address,
    required String description,
    required List<Room> rooms,
  })  : _id = id,
        _name = name,
        _address = address,
        _description = description,
        _rooms = rooms;

  // Factory: Chuyển dữ liệu từ Firebase về App
  factory Hotel.fromJson(Map<String, dynamic> json) {
    // Chuyển đổi danh sách JSON con thành danh sách đối tượng Room
    var roomList = (json['rooms'] as List<dynamic>?)
        ?.map((roomJson) => Room.fromJson(roomJson))
        .toList() ?? [];

    return Hotel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      description: json['description'] ?? '',
      rooms: roomList,
    );
  }

  // Getters
  String get id => _id;
  String get name => _name;
  String get address => _address;
  String get description => _description;
  List<Room> get rooms => _rooms;

  // Setters
  set id(String value) => _id = value;
  set name(String value) => _name = value;
  set address(String value) => _address = value;
  set description(String value) => _description = value;
  set rooms(List<Room> value) => _rooms = value;

  // toJson: Chuyển đối tượng thành JSON để đẩy lên Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'name': _name,
      'address': _address,
      'description': _description,
      'rooms': _rooms.map((room) => room.toJson()).toList(), // Chuyển từng phòng về dạng JSON
    };
  }
}