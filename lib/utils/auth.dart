import 'package:amplify_flutter/amplify_flutter.dart';

class AuthService {
  /// Đăng ký tài khoản
  Future<void> signUp(String email, String password) async {
    try {
      final result = await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: SignUpOptions(
          userAttributes: {
            AuthUserAttributeKey.email: email, // Sử dụng AuthUserAttributeKey.email
          },
        ),
      );
      print('Đăng ký thành công: ${result.isSignUpComplete}');
    } on AuthException catch (e) {
      // Kiểm tra nếu lỗi là do email đã tồn tại
      if (e.message.contains('UsernameExistsException')) {
        throw Exception('Email đã được đăng ký. Vui lòng sử dụng email khác hoặc đăng nhập.');
      }
      // Ném lại lỗi khác nếu không phải lỗi UsernameExistsException
      throw Exception('Lỗi đăng ký: ${e.message}');
    } catch (e) {
      print('Đăng ký thất bại: $e');
      throw Exception('Đã xảy ra lỗi khi đăng ký tài khoản.');
    }
  }

  /// Xác thực OTP
  Future<void> confirmSignUp(String email, String confirmationCode) async {
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: email,
        confirmationCode: confirmationCode,
      );
      print('Xác thực OTP thành công: ${result.isSignUpComplete}');
    } catch (e) {
      print('Xác thực OTP thất bại: $e');
      throw Exception('Xác thực OTP thất bại. Vui lòng kiểm tra mã xác thực.');
    }
  }

  /// Đăng nhập
  Future<bool> signIn(String email, String password) async {
    try {
      await Amplify.Auth.signIn(
        username: email,
        password: password,
      );
      print('Đăng nhập thành công');
      return true;
    } catch (e) {
      print('Đăng nhập thất bại: $e');
      throw Exception('Đăng nhập thất bại. Vui lòng kiểm tra thông tin.');
    }
  }

  /// Hàm đăng xuất
  Future<void> signOut() async {
    try {
      await Amplify.Auth.signOut();
      print('Đăng xuất thành công');
    } catch (e) {
      print('Đăng xuất thất bại: $e');
      throw Exception('Đăng xuất thất bại');
    }
  }

  /// Lấy tên người dùng hiện tại
  Future<String?> getCurrentUsername() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      return user.username; // Trả về username
    } catch (e) {
      print('Lỗi lấy thông tin tài khoản: $e');
      throw Exception('Không thể lấy thông tin tài khoản.');
    }
  }
}