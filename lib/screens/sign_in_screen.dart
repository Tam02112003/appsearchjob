import 'package:appsearchjob/models/theme_class.dart';
import 'package:appsearchjob/screens/main_screen.dart';
import 'package:appsearchjob/screens/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appsearchjob/utils/auth.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthService authService = AuthService();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscureText = true; // Biến để kiểm soát việc hiển thị mật khẩu
  String? _errorMessage; // Biến để lưu thông báo lỗi
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Truy cập ThemeProvider

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white, // Nền sáng hơn trong chế độ tối
      appBar: AppBar(
        title: Text(
          'Đăng nhập',
          style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
        ),
        backgroundColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset('assets/logo.png', height: 100),
            SizedBox(height: 20),

            // Email Field
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: themeProvider.isDarkMode ? Colors.white70 : Colors.black), // Màu chữ nhãn
                border: OutlineInputBorder(),
                filled: true,
                fillColor: themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[300], // Màu nền của TextField
              ),
              style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black), // Màu chữ trong TextField
            ),
            SizedBox(height: 16),

            // Password Field
            TextField(
              controller: passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                labelStyle: TextStyle(color: themeProvider.isDarkMode ? Colors.white70 : Colors.black),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[300],
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText; // Đảo ngược trạng thái hiển thị
                    });
                  },
                ),
              ),
              style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
            ),
            SizedBox(height: 20),
            // Hiển thị thông báo lỗi nếu có
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),

            // Sign In Button
            ElevatedButton(
              onPressed: () async {
                final username = usernameController.text;
                final password = passwordController.text;

                // Kiểm tra thông tin đầu vào
                if (username.isEmpty || password.isEmpty) {
                  _showErrorDialog('Vui lòng nhập cả email và mật khẩu.');
                  return;
                }

                try {
                  final success = await authService.signIn(username, password);
                  if (success) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  } else {
                    _showErrorDialog('Đăng nhập thất bại. Tài khoản hoặc mật khẩu không đúng.');
                  }
                } catch (e) {
                  // Xử lý các lỗi cụ thể
                  if (e.toString().contains('Network error')) {
                    _showErrorDialog('Lỗi kết nối. Vui lòng kiểm tra internet của bạn.');
                  } else if (e.toString().contains('Invalid credentials')) {
                    _showErrorDialog('Tài khoản hoặc mật khẩu không đúng.');
                  } else {
                    _showErrorDialog('Đã có lỗi xảy ra: ${e.toString()}');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: themeProvider.isDarkMode ? Color(0xFF1DB954) : Colors.blue, // Màu nút
                textStyle: TextStyle(fontSize: 16),
              ),
              child: Text('Đăng nhập', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 20),

            // Sign Up Option
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Bạn chưa có tài khoản?', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white70 : Colors.black)),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                    // Chuyển đến trang đăng ký
                  },
                  child: Text(
                    'Đăng ký',
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white : Colors.white, // Màu sắc nút đăng ký
                      fontWeight: FontWeight.bold, // In đậm để nổi bật
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
  // Hàm hiển thị thông báo lỗi dạng popup
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Lỗi'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('Đóng'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}