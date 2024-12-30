import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Thêm import cho DateFormat
import 'package:appsearchjob/models/theme_class.dart'; // Đảm bảo đã import ThemeProvider
import '../models/job_class.dart';
import '../services/api_service.dart';

class JobPostScreen extends StatefulWidget {
  const JobPostScreen({super.key});

  @override
  _JobPostScreenState createState() => _JobPostScreenState();
}

class _JobPostScreenState extends State<JobPostScreen> {
  final ApiService _apiService = ApiService('https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage/job');
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();

  DateTime? selectedDeadline; // Biến để lưu ngày và giờ đã chọn

  Future<void> _selectDeadline(BuildContext context) async {
    // Mở DatePicker để chọn ngày
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    // Nếu ngày được chọn, mở TimePicker để chọn giờ và phút
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDeadline ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          // Kết hợp ngày và giờ đã chọn
          selectedDeadline = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          deadlineController.text = DateFormat('yyyy-MM-dd HH:mm').format(selectedDeadline!); // Cập nhật controller
        });
      }
    }
  }

  Future<void> _createPost() async {
    // Kiểm tra nếu tiêu đề hoặc mô tả trống
    if (titleController.text.isEmpty || descriptionController.text.isEmpty ||
        companyController.text.isEmpty || locationController.text.isEmpty ||
        salaryController.text.isEmpty || deadlineController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng điền đầy đủ thông tin.')),
      );
      return; // Dừng lại nếu không hợp lệ
    }

    // Kiểm tra xem lương có phải là số hợp lệ không
    double? salary = double.tryParse(salaryController.text);
    if (salary == null || salary < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập lương hợp lệ')),
      );
      return; // Dừng hàm nếu lương không hợp lệ
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
      deadline: selectedDeadline, // Sử dụng ngày và giờ đã chọn
      isHidden: false, // Đặt mặc định isHidden là false
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

  // Hàm tạo JobID
  String generateJobId() {
    return 'job_${DateTime.now().millisecondsSinceEpoch}'; // Tạo ID duy nhất
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Truy cập vào ThemeProvider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng tin tuyển dụng'),
        backgroundColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.blueAccent,
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
              GestureDetector(
                onTap: () => _selectDeadline(context), // Mở DatePicker và TimePicker khi nhấn
                child: AbsorbPointer( // Ngăn không cho nhập tay
                  child: _buildTextField('Hạn nộp (YYYY-MM-DD HH:mm)', deadlineController, Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _createPost,
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
      backgroundColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
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
      style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
      cursorColor: themeProvider.isDarkMode ? Colors.white : Colors.blueAccent,
    );
  }
}