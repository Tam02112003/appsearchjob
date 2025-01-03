import 'package:appsearchjob/models/theme_class.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    // Lấy trạng thái hiện tại từ ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _isDarkMode = themeProvider.isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cài đặt', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black)),
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Chọn chế độ sáng/tối
            ListTile(
              title: Text(
                'Chế độ tối',
                style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
              ),
              trailing: Switch(
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value; // Cập nhật trạng thái nội bộ
                  });
                  themeProvider.toggleTheme(); // Thay đổi chế độ trong ThemeProvider
                },
                activeColor: const Color(0xFF1DB954), // Màu cho nút bật
              ),
            ),
          ],
        ),
      ),
    );
  }
}