class User {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? token;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.token,
  });

  // Tambahkan factory method untuk membuat User dari JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      token: json['token'],
    );
  }

  // Tambahkan method untuk mengkonversi User ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'token': token,
    };
  }
}
