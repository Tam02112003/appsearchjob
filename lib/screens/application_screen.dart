import 'package:appsearchjob/models/job_class.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:appsearchjob/models/theme_class.dart'; // Đảm bảo import ThemeProvider

class ApplicationScreen extends StatefulWidget {
  final JobPost job;

  const ApplicationScreen({super.key, required this.job});

  @override
  _ApplicationScreenState createState() => _ApplicationScreenState();
}

class _ApplicationScreenState extends State<ApplicationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _cvFile;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _cvFile = File(image.path);
      });
    }
  }

  Future<void> _pickFile() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _cvFile = File(file.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ứng tuyển: ${widget.job.title}'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Điền thông tin ứng tuyển',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildTextField('Họ và tên', _nameController, Icons.person, themeProvider),
              const SizedBox(height: 16),
              _buildTextField('Email', _emailController, Icons.email, themeProvider),
              const SizedBox(height: 16),
              _buildTextField('Số điện thoại', _phoneController, Icons.phone, themeProvider),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _cvFile != null
                          ? 'Hình ảnh CCCD: ${_cvFile!.path.split('/').last}'
                          : 'Chưa chọn hình ảnh CCCD',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black54),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: _pickFile,
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: _pickImage,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Hành động khi nhấn nút gửi
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.isDarkMode ? Colors.blueGrey : Colors.blue, // Màu nền theo chế độ
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Gửi đơn ứng tuyển',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, ThemeProvider themeProvider) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: themeProvider.isDarkMode ? Colors.white : Colors.blueAccent), // Màu biểu tượng
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: themeProvider.isDarkMode ? Colors.white : Colors.blueAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: themeProvider.isDarkMode ? Colors.white : Colors.blueAccent, width: 2.0),
        ),
      ),
      style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black), // Màu văn bản
      cursorColor: themeProvider.isDarkMode ? Colors.white : Colors.blueAccent, // Màu con trỏ
    );
  }
}