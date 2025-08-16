class UserModel {
  final int id;
  final String fname;
  final String lname;
  final String email;
  final String? phone;
  final String role;

  UserModel({
    required this.id,
    required this.fname,
    required this.lname,
    required this.email,
    this.phone,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      fname: json["fname"],
      lname: json["lname"],
      email: json["email"],
      phone: json["phone"],
      role: json["role"] ?? "user",
    );
  }
}
