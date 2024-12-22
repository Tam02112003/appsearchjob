import 'package:appsearchjob/models/theme_class.dart';
import 'package:appsearchjob/screens/confirm_sign_up_screen.dart';
import 'package:appsearchjob/screens/sign_in_screen.dart';
import 'package:appsearchjob/utils/auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Kiểm tra mật khẩu hợp lệ
  bool isPasswordValid(String password) {
    final RegExp passwordRegExp = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$',
    );
    return passwordRegExp.hasMatch(password);
  }

  void _signUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Kiểm tra các điều kiện
    if (email.isEmpty || !EmailValidator.validate(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(email.isEmpty ? 'Email không được để trống' : 'Địa chỉ email không hợp lệ')),
      );
      return;
    }
    if (password.isEmpty || !isPasswordValid(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu không hợp lệ.')),
      );
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu và xác nhận mật khẩu không khớp')),
      );
      return;
    }

    try {
      await _authService.signUp(email, password);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OtpScreen(email: email)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Truy cập ThemeProvider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký tài khoản'),
        backgroundColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset('assets/logo.png', height: 100), // Thêm logo
            const SizedBox(height: 20),

            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[200], // Màu nền
                labelStyle: TextStyle(color: themeProvider.isDarkMode ? Colors.white70 : Colors.black),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[200],
                labelStyle: TextStyle(color: themeProvider.isDarkMode ? Colors.white70 : Colors.black),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Xác nhận mật khẩu',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[200],
                labelStyle: TextStyle(color: themeProvider.isDarkMode ? Colors.white70 : Colors.black),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _signUp,
              child: const Text('Đăng ký'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1DB954) : Colors.blue, // Màu nút
                textStyle: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Bạn muốn đăng nhập ?', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black)),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignInScreen()),
                    );
                  },
                  child: Text(
                    'Đăng nhập',
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}