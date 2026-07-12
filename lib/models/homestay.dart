class Homestay {
  String _id;
  String _name;
  String _hostName;
  String _address;
  String _description;

  Homestay({
    required String id,
    required String name,
    required String hostName,
    required String address,
    required String description,
  })  : _id = id,
        _name = name,
        _hostName = hostName,
        _address = address,
        _description = description;

  factory Homestay.fromJson(Map<String, dynamic> json) {
    return Homestay(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      hostName: json['hostName'] ?? '',
      address: json['address'] ?? '',
      description: json['description'] ?? '',
    );
  }

  // Getters & Setters
  String get id => _id;
  String get name => _name;
  String get hostName => _hostName;
  String get address => _address;
  String get description => _description;

  set id(String value) => _id = value;
  set name(String value) => _name = value;
  set hostName(String value) => _hostName = value;
  set address(String value) => _address = value;
  set description(String value) => _description = value;

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'name': _name,
      'hostName': _hostName,
      'address': _address,
      'description': _description,
    };
  }
}