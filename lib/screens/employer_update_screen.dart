import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appsearchjob/models/theme_class.dart';

class EmployerUpdateScreen extends StatefulWidget {
  const EmployerUpdateScreen({super.key});

  @override
  _EmployerUpdateScreenState createState() => _EmployerUpdateScreenState();
}

class _EmployerUpdateScreenState extends State<EmployerUpdateScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final _formKey = GlobalKey<FormState>();
  String? companyName;
  String? contactPerson;
  String? email;
  String? phoneNumber;
  String? website;
  String? address;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(); // Lặp lại mãi mãi

    _animation = Tween<double>(begin: 1.0, end: -1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Truy cập ThemeProvider

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.blue,
        title: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(MediaQuery.of(context).size.width * _animation.value, 0),
              child: Container(
                width: MediaQuery.of(context).size.width * 2, // Đảm bảo chiều rộng đủ lớn
                child: Text(
                  'Cập nhật thông tin nhà tuyển dụng',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  overflow: TextOverflow.visible, // Đảm bảo văn bản không bị cắt
                ),
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Tên công ty',
                  filled: true,
                  fillColor: themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[200], // Màu nền
                  labelStyle: TextStyle(color: themeProvider.isDarkMode ? Colors.white70 : Colors.black),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên công ty';
                  }
                  return null;
                },
                onSaved: (value) {
                  companyName = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Người liên hệ',
                  filled: true,
                  fillColor: themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[200],
                  labelStyle: TextStyle(color: themeProvider.isDarkMode ? Colors.white70 : Colors.black),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên người liên hệ';
                  }
                  return null;
                },
                onSaved: (value) {
                  contactPerson = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[200],
                  labelStyle: TextStyle(color: themeProvider.isDarkMode ? Colors.white70 : Colors.black),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Vui lòng nhập địa chỉ email hợp lệ';
                  }
                  return null;
                },
                onSaved: (value) {
                  email = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  filled: true,
                  fillColor: themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[200],
                  labelStyle: TextStyle(color: themeProvider.isDarkMode ? Colors.white70 : Colors.black),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || !RegExp(r'^\d+$').hasMatch(value)) {
                    return 'Vui lòng nhập số điện thoại hợp lệ';
                  }
                  return null;
                },
                onSaved: (value) {
                  phoneNumber = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Website',
                  filled: true,
                  fillColor: themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[200],
                  labelStyle: TextStyle(color: themeProvider.isDarkMode ? Colors.white70 : Colors.black),
                ),
                onSaved: (value) {
                  website = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Địa chỉ',
                  filled: true,
                  fillColor: themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[200],
                  labelStyle: TextStyle(color: themeProvider.isDarkMode ? Colors.white70 : Colors.black),
                ),
                onSaved: (value) {
                  address = value;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Thực hiện cập nhật thông tin ở đây
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thông tin đã được cập nhật!')),
                    );
                  }
                },
                child: const Text('Cập nhật'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Thay đổi màu nút nếu cần
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: EmployerUpdateScreen(),
  ));
}