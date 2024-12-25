import 'package:appsearchjob/models/application_class.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
        height: MediaQuery.of(context).size.height, // Đảm bảo container chiếm toàn bộ chiều cao
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
                child: CircleAvatar(
                  backgroundImage: NetworkImage(application.image),
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  child: ClipOval(
                    child: Image.network(
                      application.image,
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error, size: 60);
                      },
                    ),
                  ),
                ),
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
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          title: const Text('Phản hồi ứng viên'),
          content: const Text('Bạn muốn chấp nhận hay từ chối ứng viên này?'),
          actions: [
            TextButton(
              onPressed: () {
                _handleResponse(context, 'accepted');
              },
              child: const Text('Chấp nhận'),
            ),
            TextButton(
              onPressed: () {
                _handleResponse(context, 'rejected');
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

  void _handleResponse(BuildContext context, String response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bạn đã ${response == 'accepted' ? 'chấp nhận' : 'từ chối'} ứng viên ${application.name}')),
    );

    Navigator.of(context).pop(); // Đóng dialog sau khi phản hồi
  }
}