import 'package:amplify_flutter/amplify_flutter.dart';
import 'dart:convert'; // Import thư viện jsonEncode
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';         // Thư viện Amplify API cần được import
class AuthService {
  /// Đăng ký tài khoản
  Future<void> signUp(String email, String password) async {
    try {
      final result = await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: SignUpOptions(
            userAttributes: {
              AuthUserAttributeKey.email: email,
            }
        ),
      );
      if (result.isSignUpComplete) {
        print('Đăng ký thành công');
      }
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
  Future<String?> signIn(String email, String password) async {
    try {
      // Kiểm tra xem người dùng đã đăng nhập hay chưa
      final session = await Amplify.Auth.fetchAuthSession();
      if (session.isSignedIn) {
        return 'Người dùng đã đăng nhập. Vui lòng đăng xuất trước khi đăng nhập lại.';
      }

      // Thực hiện đăng nhập
      await Amplify.Auth.signIn(
        username: email,
        password: password,
      );
      print('Đăng nhập thành công');
      return null; // Trả về null khi đăng nhập thành công
    } catch (e) {
      // Xử lý các lỗi cụ thể
      if (e.toString().contains('UserNotFoundException')) {
        return 'Người dùng không tồn tại. Vui lòng kiểm tra lại email.';
      } else if (e.toString().contains('NotAuthorizedException')) {
        return 'Sai mật khẩu. Vui lòng thử lại.';
      } else if (e.toString().contains('Network error')) {
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.';
      } else {
        print('Đăng nhập thất bại: $e');
        return 'Đăng nhập thất bại. Đã xảy ra lỗi: ${e.toString()}';
      }
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

  /// Lấy userId của người dùng hiện tại
  Future<String?> getCurrentUserId() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      return user.userId; // Trả về userId
    } catch (e) {
      print('Lỗi lấy userId: $e');
      throw Exception('Không thể lấy userId.');
    }
  }

}

