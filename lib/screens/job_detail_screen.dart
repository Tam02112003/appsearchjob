import 'package:appsearchjob/models/theme_class.dart';
import 'package:appsearchjob/screens/application_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job_class.dart';

class JobDetailScreen extends StatelessWidget {
  final JobPost job;

  const JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết: ${job.title}', style: const TextStyle(color: Colors.white)),
        backgroundColor: isDarkMode ? Colors.black : Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề công việc
            Text(
              job.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            // Mô tả công việc
            Text(
              job.description,
              style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54, fontSize: 16),
            ),
            const SizedBox(height: 16),
            // Thông tin bổ sung
            const Text(
              'Thông tin bổ sung:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '• Địa điểm: ${job.location}\n'
                  '• Lương: ${job.salary.toString()} VNĐ\n' // Hiển thị lương và đơn vị
                  '• Công ty: ${job.company}\n', // Thêm thông tin công ty
              style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54, fontSize: 16),
            ),
            const SizedBox(height: 20),
            // Nút ứng tuyển
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ApplicationScreen(job: job)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? Colors.blueAccent : Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Ứng tuyển ngay',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}