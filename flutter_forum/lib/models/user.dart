class User {
  final String? id;
  final String username;
  final String password; // You may not want to store passwords in Firestore for security reasons

  User({
    this.id,
    required this.username,
    required this.password,
  });

  // Convert User object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
    };
  }

  // Convert User object to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      // You should handle passwords securely, e.g., hash before storing
      'password': password,
    };
  }

  // Create a User object from a map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
    );
  }

  // Create a User object from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'], // Include the id field
      username: json['username'],
      password: json['password'],
    );
  }

}
