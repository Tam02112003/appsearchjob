import 'dart:convert';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
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
        throw Exception(
            'Email đã được đăng ký. Vui lòng sử dụng email khác hoặc đăng nhập.');
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

  /// Kiểm tra xem người dùng đã đăng nhập hay chưa
  Future<bool> isUserLoggedIn() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      return session.isSignedIn; // Trả về true nếu người dùng đã đăng nhập
    } catch (e) {
      print('Lỗi kiểm tra trạng thái đăng nhập: $e');
      throw Exception('Không thể kiểm tra trạng thái đăng nhập.');
    }
  }

  /// Thay đổi mật khẩu
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await Amplify.Auth.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      print('Thay đổi mật khẩu thành công');
    } on AuthException catch (e) {
      print('Thay đổi mật khẩu thất bại: $e');
      // Kiểm tra loại lỗi và ném ra thông báo tương ứng
      if (e.message.contains('Incorrect password')) {
        throw Exception('Mật khẩu hiện tại không đúng.');
      } else if (e.message.contains('WeakPasswordException')) {
        throw Exception(
            'Mật khẩu mới không đủ mạnh. Vui lòng chọn mật khẩu khác.');
      } else {
        throw Exception('Lỗi thay đổi mật khẩu: ${e.message}');
      }
    } catch (e) {
      print('Đã xảy ra lỗi khi thay đổi mật khẩu: $e');
      throw Exception('Lỗi không xác định khi thay đổi mật khẩu.');
    }
  }

  /// Lấy danh sách nhóm của người dùng hiện tại
  Future<List<String>> getUserGroups() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();

      if (!session.isSignedIn) {
        throw Exception('Người dùng chưa đăng nhập.');
      }

      // Lấy thông tin user pool tokens
      final authSession = session as CognitoAuthSession;
      final accessToken = authSession.userPoolTokens?.accessToken.raw;

      // Kiểm tra nếu access token không null
      if (accessToken != null) {
        // Giải mã payload từ access token
        final parts = accessToken.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          final decodedPayload = utf8.decode(base64Url.decode(base64Url.normalize(payload)));
          final Map<String, dynamic> userData = jsonDecode(decodedPayload);

          // Lấy nhóm từ payload
          final List<String> groups = List<String>.from(userData['cognito:groups'] ?? []);
          return groups;
        }
      }
      return [];
    } catch (e) {
      print('Lỗi lấy nhóm người dùng: $e');
      throw Exception('Không thể lấy nhóm người dùng.');
    }
  }

  /// Kiểm tra xem người dùng hiện tại có thuộc nhóm cụ thể hay không
  Future<bool> isUserInGroup(String groupName) async {
    try {
      // Lấy danh sách nhóm của người dùng
      final userGroups = await getUserGroups();

      // Kiểm tra xem nhóm có tồn tại trong danh sách hay không
      return userGroups.contains(groupName);
    } catch (e) {
      print('Lỗi khi kiểm tra nhóm người dùng: $e');
      return false;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await Amplify.Auth.resetPassword(username: email);
      print('Mã xác nhận đã được gửi đến email: $email');
    } catch (e) {
      print('Lỗi khi yêu cầu đặt lại mật khẩu: $e');
      throw e;
    }
  }

  Future<void> confirmResetPassword(
      String email, String confirmationCode, String newPassword) async {
    try {
      await Amplify.Auth.confirmResetPassword(
        username: email,
        newPassword: newPassword,
        confirmationCode: confirmationCode,
      );
      print('Mật khẩu đã được thay đổi thành công.');
    } catch (e) {
      print('Lỗi khi xác nhận đặt lại mật khẩu: $e');
      throw e;
    }
  }
}
