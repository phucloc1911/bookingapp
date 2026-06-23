class User {
  String _id;
  String _name;
  String _email;
  String _phoneNumber;

  User({required String id, required String name, required String email, required String phoneNumber})
      : _id = id,
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


  // Hàm từ điển: Chuyển đối tượng User trong App thành JSON để đẩy lên Firebase/API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }
}
