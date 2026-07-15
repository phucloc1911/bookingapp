class User {
  String _id;
  String _name;
  String _email;
  String _phoneNumber;

  User({
    required String id,
    required String name,
    required String email,
    required String phoneNumber,
  }) : _id = id,
       _name = name,
       _email = email,
       _phoneNumber = phoneNumber;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }

  // Getters
  String get id => _id;
  String get name => _name;
  String get email => _email;
  String get phoneNumber => _phoneNumber;

  // Setters
  set id(String value) => _id = value;
  set name(String value) => _name = value;
  set email(String value) => _email = value;
  set phoneNumber(String value) => _phoneNumber = value;

  // Hàm chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'name': _name,
      'email': _email,
      'phoneNumber': _phoneNumber,
    };
  }
}
