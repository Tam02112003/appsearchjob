import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:appsearchjob/models/application_class.dart';
import '../services/api_service.dart';

class ApplicationDetailsScreen extends StatelessWidget {
  final JobApplication application;

  const ApplicationDetailsScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn ứng tuyển'),
        backgroundColor: isDarkMode ? Colors.blueGrey[900] : Colors.blueAccent,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? LinearGradient(
            colors: [Colors.black87, Colors.grey[850]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : LinearGradient(
            colors: [Colors.white, Colors.blue[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: _buildImage(context, application.image),
              ),
              const SizedBox(height: 20),
              Text(
                'Tên ứng viên: ${application.name}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              _buildInfoCard('Số điện thoại:', application.phone, isDarkMode),
              const SizedBox(height: 10),
              _buildInfoCard('Trình độ học vấn:', application.education, isDarkMode),
              const SizedBox(height: 10),
              _buildInfoCard('Kinh nghiệm:', application.experience, isDarkMode),
              const SizedBox(height: 10),
              _buildInfoCard('Trạng thái:', application.status, isDarkMode,),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () => _showResponseDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? Colors.blueGrey[700] : Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Phản hồi ứng viên'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, bool isDarkMode) {
    return Card(
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.black,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResponseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {

        return AlertDialog(
          title: const Text('Phản hồi ứng viên'),
          content: const Text('Bạn muốn chấp nhận hay từ chối ứng viên này?'),
          actions: [
            TextButton(
              onPressed: () {
                _handleResponse(context, application.id, 'Chấp nhận');
              },
              child: const Text('Chấp nhận'),
            ),
            TextButton(
              onPressed: () {
                _handleResponse(context, application.id, 'Từ chối');
              },
              child: const Text('Từ chối'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Đóng dialog
              },
              child: const Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImage(BuildContext context,String? imagePath) {
    // Kiểm tra xem imagePath có phải là null hay không
    if (imagePath == null || imagePath.isEmpty) {
      return Image.asset('assets/logo.png', width: 300);
    }

    Widget imageWidget;

    // Kiểm tra nếu là web hoặc imagePath bắt đầu bằng 'http'
    if (kIsWeb || imagePath.startsWith('http')) {
      imageWidget = Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error, size: 100); // Kích thước lớn hơn cho biểu tượng lỗi
        },
      );
    } else {
      imageWidget = Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error, size: 100); // Kích thước lớn hơn cho biểu tượng lỗi
        },
      );
    }

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: PhotoView(
                imageProvider: kIsWeb || imagePath.startsWith('http')
                    ? NetworkImage(imagePath)
                    : FileImage(File(imagePath)),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
              ),
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 120,
          height: 120,
          child: imageWidget,
        ),
      ),
    );
  }

  void _handleResponse(BuildContext context, String applicationId, String status) async {
    final apiService = ApiService(
        'https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      await apiService.updateApplicationStatus(applicationId, status);
      Navigator.of(context).pop(); // Đóng loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật trạng thái thành công: $status')),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      Navigator.of(context).pop(); // Đóng loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $error')),
      );
    }
  }
}