class AdminUser {
  final String id;
  final String email;
  final String name;

  AdminUser({
    required this.id,
    required this.email,
    required this.name,
  });

  factory AdminUser.fromMap(Map<String, dynamic> data, String id) {
    return AdminUser(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
    };
  }
}
