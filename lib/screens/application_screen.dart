import 'package:appsearchjob/models/application_class.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:appsearchjob/models/theme_class.dart';
import 'package:appsearchjob/services/api_service.dart';
import '../models/job_class.dart';
import '../utils/auth.dart'; // Import API service

class ApplicationScreen extends StatefulWidget {
  final JobPost job;

  const ApplicationScreen({Key? key, required this.job}) : super(key: key);

  @override
  _ApplicationScreenState createState() => _ApplicationScreenState();
}

class _ApplicationScreenState extends State<ApplicationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
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

  Future<void> _submitApplication() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty || _cvFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng điền đầy đủ thông tin ứng tuyển!')),
      );
      return;
    }
    // Kiểm tra định dạng số điện thoại Việt Nam
    final phoneRegex = RegExp(r'^(0[1-9]\d{8})$'); // Định dạng số điện thoại Việt Nam
    if (!phoneRegex.hasMatch(_phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Số điện thoại không hợp lệ!')),
      );
      return; // Dừng hàm nếu số điện thoại không hợp lệ
    }
    // Lấy userId
    String? userId;
    try {
      userId = await AuthService().getCurrentUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể lấy userId.')),
        );
        return; // Dừng hàm nếu không lấy được userId
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lấy userId: $e')),
      );
      return; // Dừng hàm nếu có lỗi khi lấy userId
    }

    JobApplication application = JobApplication(
      education: _educationController.text,
      experience: _experienceController.text,
      image: _cvFile!.path, // Đường dẫn đến file hình ảnh
      jobId: widget.job.id, // Lấy jobId từ widget.job.id
      name: _nameController.text,
      phone: _phoneController.text,
      userId: userId,
    );

    final ApiService apiService = ApiService('https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage');
    try {
      await apiService.sendApplication(application);
      _notifyNewApplication(application); // Gọi hàm gửi thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đơn ứng tuyển đã được gửi!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gửi đơn ứng tuyển thất bại: $e')),
      );
    }
  }

  void _notifyNewApplication(JobApplication application) {
    // Tạo thông báo cho ứng tuyển mới
    final snackBar = SnackBar(
      content: Text('${application.name} đã ứng tuyển cho công việc ${widget.job.title}.'),
      // action: SnackBarAction(
      //   label: 'Xem',
      //   onPressed: () {
      //     // Điều hướng đến màn hình chi tiết đơn ứng tuyển nếu cần
      //   },
      // ),
    );

    // Hiển thị thông báo
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
              _buildTextField('Trình độ học vấn', _educationController, Icons.school, themeProvider),
              const SizedBox(height: 16),
              _buildTextField('Kinh nghiệm làm việc', _experienceController, Icons.work, themeProvider),
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
                  onPressed: _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.isDarkMode ? Colors.blueGrey : Colors.blue,
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
        prefixIcon: Icon(icon, color: themeProvider.isDarkMode ? Colors.white : Colors.blueAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: themeProvider.isDarkMode ? Colors.white : Colors.blueAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: themeProvider.isDarkMode ? Colors.white : Colors.blueAccent, width: 2.0),
        ),
      ),
      style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
      cursorColor: themeProvider.isDarkMode ? Colors.white : Colors.blueAccent,
    );
  }
}