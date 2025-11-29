class User {
  final int? id;
  final String email;
  final String password;
  final String fullName;
  final String phoneNumber;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.fullName,
    required this.phoneNumber,
  });

  // Conversion de l'objet User en Map pour JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
    };
  }

  // Création d'un User à partir d'un Map (JSON)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      password: json['password'] ?? '',
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
    );
  }
}