import 'package:appsearchjob/models/theme_class.dart';
import 'package:appsearchjob/screens/application_screen.dart';
import 'package:appsearchjob/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/job_class.dart';
import '../utils/auth.dart';

class JobDetailScreen extends StatelessWidget {
  final JobPost job;
  final AuthService _authService = AuthService();

  JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết: ${job.title}', style: const TextStyle(color: Colors.white)),
        backgroundColor: isDarkMode ? Colors.black : Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh công việc
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage('assets/congviec.jpg'), // Thay thế bằng hình ảnh thực tế
                  fit: BoxFit.cover,
                ),
              ),
              height: 200,
              width: double.infinity,
            ),
            const SizedBox(height: 16),
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
                  '• Lương: ${job.salary.toString()} VNĐ\n'
                  '• Công ty: ${job.company}\n',
              style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54, fontSize: 16),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  color: isDarkMode ? Colors.white54 : Colors.black54,
                ),
                children: [
                  const TextSpan(text: 'Hạn nộp hồ sơ: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  TextSpan(
                    text: job.deadline != null
                        ? DateFormat('dd-MM-yyyy HH:mm').format(job.deadline!)
                        : 'Chưa có hạn nộp',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Nút ứng tuyển
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  bool isLoggedIn = await _authService.isUserLoggedIn();

                  if (isLoggedIn) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ApplicationScreen(job: job),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignInScreen(),
                      ),
                    );
                  }
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