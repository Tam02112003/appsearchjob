import 'package:flutter/material.dart';
import '../utils/auth.dart';


class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isCodeSent = false; // Trạng thái để hiển thị giao diện phù hợp

  void _sendResetCode() async {
    final email = emailController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập email')),
      );
      return;
    }

    try {
      await _authService.resetPassword(email);
      setState(() {
        isCodeSent = true; // Chuyển sang bước nhập mã xác nhận
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mã xác nhận đã được gửi đến email của bạn')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  void _confirmResetPassword() async {
    final email = emailController.text;
    final code = codeController.text;
    final newPassword = passwordController.text;

    if (code.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    try {
      await _authService.confirmResetPassword(email, code, newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đặt lại mật khẩu thành công!')),
      );
      Navigator.pop(context); // Quay lại màn hình trước (ví dụ: màn hình đăng nhập)
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quên mật khẩu')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị bước phù hợp dựa trên trạng thái isCodeSent
            if (!isCodeSent) ...[
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendResetCode,
                child: Text('Gửi mã xác nhận'),
              ),
            ] else ...[
              TextField(
                controller: codeController,
                decoration: InputDecoration(labelText: 'Mã xác nhận'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Mật khẩu mới'),
                obscureText: true,
              ),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(labelText: 'Xác nhận mật khẩu mới'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _confirmResetPassword,
                child: Text('Xác nhận'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
