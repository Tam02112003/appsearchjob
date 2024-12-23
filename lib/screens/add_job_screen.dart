import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appsearchjob/models/theme_class.dart'; // Đảm bảo đã import ThemeProvider
import '../models/job_class.dart';
import '../services/api_service.dart';
class JobPostScreen extends StatefulWidget {
  const JobPostScreen({super.key});

  @override
  _JobPostScreenState createState() => _JobPostScreenState();
}

class _JobPostScreenState extends State<JobPostScreen> {
  final ApiService _apiService = ApiService('https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage/job'); // Thay bằng URL của bạn
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();



  Future<void> _createPost() async {
    // Kiểm tra nếu tiêu đề hoặc mô tả trống
    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng điền đầy đủ thông tin.')),
      );
      return; // Dừng lại nếu không hợp lệ
    }

    // Lấy userId từ Cognito
    String currentUserId;
    try {
      var user = await Amplify.Auth.getCurrentUser();
      currentUserId = user.userId; // Lưu userId
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể lấy thông tin người dùng: $e')),
      );
      return;
    }
    final newPost = JobPost(
      id: generateJobId(), // ID sẽ được tạo ra từ server
      title: titleController.text,
      description: descriptionController.text,
      company: companyController.text,
      location: locationController.text,
      salary: double.tryParse(salaryController.text) ?? 0.0,
      userId: currentUserId, // Thêm userId vào bài đăng
    );

    try {
      await _apiService.createItem(newPost.toJson());
      Navigator.pop(context, true); // Quay lại trang trước
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tạo bài đăng thất bại: $e')),
      );
    }
  }

  //Hàm tạo JobID
  String generateJobId() {
    return 'job_${DateTime.now().millisecondsSinceEpoch}'; // Tạo ID duy nhất
  }
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Truy cập vào ThemeProvider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng tin tuyển dụng'),
        backgroundColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.blueAccent, // Sử dụng màu xám nhạt hơn
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thông tin công việc',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildTextField('Tiêu đề công việc', titleController, Icons.title),
              const SizedBox(height: 16),
              _buildTextField('Mô tả công việc', descriptionController, Icons.description),
              const SizedBox(height: 16),
              _buildTextField('Công ty', companyController, Icons.home_work),
              const SizedBox(height: 16),
              _buildTextField('Địa chỉ', locationController, Icons.home_work),

              const SizedBox(height: 16),
              _buildTextField('Lương theo giờ', salaryController, Icons.attach_money),
              const SizedBox(height: 16),
              const Text('Loại hình công việc', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: ( ) {
                    _createPost();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Đăng tin',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white, // Màu nền của body
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    final themeProvider = Provider.of<ThemeProvider>(context);

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
      style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black), // Màu chữ trong TextField
      cursorColor: themeProvider.isDarkMode ? Colors.white : Colors.blueAccent, // Màu con trỏ
    );
  }
}