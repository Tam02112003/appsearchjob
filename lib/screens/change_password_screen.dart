import 'package:flutter/material.dart';
import '../utils/auth.dart'; // Đảm bảo đường dẫn chính xác đến AuthService

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService(); // Khởi tạo AuthService

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  void _changePassword() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword == confirmPassword) {
      try {
        // Gọi phương thức thay đổi mật khẩu
        await _authService.changePassword(currentPassword, newPassword);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mật khẩu đã được thay đổi!')),
        );
        Navigator.pop(context); // Đóng màn hình
      } catch (e) {
        // Kiểm tra lỗi và hiển thị thông báo tương ứng
        String message;
        if (e.toString().contains('Incorrect password')) {
          message = 'Mật khẩu hiện tại không đúng!';
        } else if (e.toString().contains('WeakPasswordException')) {
          message = 'Mật khẩu mới không đủ mạnh. Vui lòng chọn mật khẩu khác.';
        } else if (e.toString().contains('LimitExceededException')) {
          message = 'Đã vượt quá số lần thử. Vui lòng thử lại sau.';
        } else {
          message = 'Lỗi thay đổi mật khẩu: ${e.toString()}';
        }
        // Hiển thị thông báo lỗi lên màn hình
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mật khẩu mới không khớp!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thay đổi mật khẩu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPasswordField(
                controller: _currentPasswordController,
                label: 'Mật khẩu hiện tại',
                obscureText: _obscureCurrentPassword,
                onToggle: () {
                  setState(() {
                    _obscureCurrentPassword = !_obscureCurrentPassword;
                  });
                }),
            _buildPasswordField(
                controller: _newPasswordController,
                label: 'Mật khẩu mới',
                obscureText: _obscureNewPassword,
                onToggle: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                }),
            _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'Xác nhận mật khẩu mới',
                obscureText: _obscureConfirmPassword,
                onToggle: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changePassword,
              child: const Text('Thay đổi mật khẩu'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}