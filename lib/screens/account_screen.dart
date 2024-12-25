import 'package:appsearchjob/screens/default_screen.dart';
import 'package:appsearchjob/screens/employer_update_screen.dart';
import 'package:appsearchjob/screens/setting_screen.dart';
import 'package:appsearchjob/utils/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/theme_class.dart';
import 'change_password_screen.dart';


class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthService _authService = AuthService();

  void _logout(BuildContext context) async {
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận đăng xuất'),
        content: Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmLogout == true) {
      try {
        await _authService.signOut();

        if (!context.mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => DefaultScreen()),
              (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng xuất thất bại: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Tài khoản'),
        backgroundColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.blueAccent,
      ),
      body: FutureBuilder<String?>(
        future: _authService.getCurrentUsername(), // Lấy tên người dùng
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Không tìm thấy thông tin người dùng.'));
          }

          final username = snapshot.data!; // Lấy tên người dùng

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    child: ClipOval(
                      child: Image.asset(
                        'assets/profile-icon.png',
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    username, // Hiển thị tên người dùng
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Thông tin cá nhân',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  //Các ListTile khác...
                  // _buildListTile(context, Icons.person, 'Cập nhật thông tin người dùng', () {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => EmployerUpdateScreen()),
                  //   );
                  // }),
                  _buildListTile(context, Icons.password, 'Thay đổi mật khẩu', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                    );
                  }),
                  _buildListTile(context, Icons.settings, 'Cài đặt', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
                  }),
                  _buildListTile(context, Icons.logout, 'Đăng xuất', () {
                    _logout(context);
                  }),
                ],
              ),
            ),
          );
        },
      ),
      backgroundColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white, // Màu nền của Card
      child: ListTile(
        leading: Icon(icon, color: themeProvider.isDarkMode ? Colors.white : Colors.blueAccent),
        title: Text(
          title,
          style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black), // Màu chữ
        ),
        onTap: onTap,
      ),
    );
  }
}