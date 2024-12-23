import 'package:amplify_flutter/amplify_flutter.dart';


class User extends Model {
final String email;
final String role;

User({required this.email, required this.role});

@override
String getId() => email; // Hoặc ID duy nhất khác nếu có

// Cần thêm các phương thức từ Model
@override
String get modelName => 'User';

@override
Map<String, dynamic> toJson() {
  return {
    'email': email,
    'role': role,
  };
}

static User fromJson(Map<String, dynamic> json) {
return User(
email: json['email'],
role: json['role'],
);
}
}