import 'package:appsearchjob/models/job_class.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Thêm import cho DateFormat
import '../services/api_service.dart';

class EditJobScreen extends StatefulWidget {
  final JobPost jobPost;

  const EditJobScreen({super.key, required this.jobPost});

  @override
  _EditJobScreenState createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {
  final ApiService _apiService = ApiService('https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage/job');
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController companyController;
  late TextEditingController locationController;
  late TextEditingController salaryController;
  late TextEditingController deadlineController; // Thêm controller cho hạn nộp
  DateTime? selectedDeadline; // Biến để lưu hạn nộp đã chọn

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.jobPost.title);
    descriptionController = TextEditingController(text: widget.jobPost.description);
    companyController = TextEditingController(text: widget.jobPost.company);
    locationController = TextEditingController(text: widget.jobPost.location);
    salaryController = TextEditingController(text: widget.jobPost.salary.toString());

    // Khởi tạo deadlineController với hạn nộp từ jobPost
    selectedDeadline = widget.jobPost.deadline; // Lưu hạn nộp vào biến selectedDeadline
    deadlineController = TextEditingController(text: selectedDeadline != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(selectedDeadline!)
        : ''); // Khởi tạo deadlineController
  }

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
          // Cập nhật giá trị cho deadlineController
          deadlineController.text = DateFormat('yyyy-MM-dd HH:mm').format(selectedDeadline!);
        });
      }
    }
  }

  void _updatePost() async {
    // Kiểm tra nếu tiêu đề hoặc mô tả trống
    if (titleController.text.isEmpty || descriptionController.text.isEmpty ||
        companyController.text.isEmpty || locationController.text.isEmpty ||
        salaryController.text.isEmpty || deadlineController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin.')),
      );
      return; // Dừng lại nếu không hợp lệ
    }

    // Kiểm tra xem lương có phải là số hợp lệ không
    double? salary = double.tryParse(salaryController.text);
    if (salary == null || salary < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập lương hợp lệ')),
      );
      return; // Dừng hàm nếu lương không hợp lệ
    }

    final updatedPost = {
      'title': titleController.text,
      'description': descriptionController.text,
      'company': companyController.text,
      'location': locationController.text,
      'salary': double.tryParse(salaryController.text) ?? 0.0,
      'deadline': selectedDeadline?.toIso8601String(), // Thêm hạn nộp vào dữ liệu cập nhật
    };

    try {
      await _apiService.updateItem(widget.jobPost.id, updatedPost);
      Navigator.pop(context, true); // Trả về true
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật bài đăng thất bại: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh Sửa Bài Đăng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Tiêu đề'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả'),
            ),
            TextField(
              controller: companyController,
              decoration: const InputDecoration(labelText: 'Công ty'),
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Địa chỉ'),
            ),
            TextField(
              controller: salaryController,
              decoration: const InputDecoration(labelText: 'Lương theo giờ'),
              keyboardType: TextInputType.number,
            ),
            GestureDetector(
              onTap: () => _selectDeadline(context), // Mở DatePicker và TimePicker khi nhấn
              child: AbsorbPointer( // Ngăn không cho nhập tay
                child: TextField(
                  controller: deadlineController,
                  decoration: const InputDecoration(labelText: 'Hạn nộp (YYYY-MM-DD HH:mm)'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updatePost,
              child: const Text('Cập Nhật Bài Đăng'),
            ),
          ],
        ),
      ),
    );
  }
}