import 'package:appsearchjob/models/job_class.dart';
import 'package:flutter/material.dart';


import '../services/api_service.dart';



class EditJobScreen extends StatefulWidget {
  final JobPost jobPost;

  EditJobScreen({required this.jobPost});

  @override
  _EditJobScreenState createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {
  final ApiService _apiService = ApiService('https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage/job'); // Thay bằng URL của bạn
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController companyController;
  late TextEditingController locationController;
  late TextEditingController salaryController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.jobPost.title);
    descriptionController = TextEditingController(text: widget.jobPost.description);
    companyController = TextEditingController(text: widget.jobPost.company);
    locationController = TextEditingController(text: widget.jobPost.location);
    salaryController = TextEditingController(text: widget.jobPost.salary.toString());
  }

  void _updatePost() async {
    final updatedPost = {
      'title': titleController.text,
      'description': descriptionController.text,
      'company': companyController.text,
      'location': locationController.text,
      'salary': double.tryParse(salaryController.text) ?? 0.0,
    };

    try {
      await _apiService.updateItem(widget.jobPost.id, updatedPost); // Gửi dữ liệu đã loại bỏ jobId
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
        title: Text('Chỉnh Sửa Bài Đăng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Tiêu đề'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Mô tả'),
            ),
            TextField(
              controller: companyController,
              decoration: InputDecoration(labelText: 'Công ty'),
            ),
            TextField(
              controller: locationController,
              decoration: InputDecoration(labelText: 'Địa chỉ'),
            ),
            TextField(
              controller: salaryController,
              decoration: InputDecoration(labelText: 'Lương theo giờ'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updatePost,
              child: Text('Cập Nhật Bài Đăng'),
            ),
          ],
        ),
      ),
    );
  }
}