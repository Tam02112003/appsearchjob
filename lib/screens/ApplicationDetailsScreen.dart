import 'package:appsearchjob/models/application_class.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ApplicationDetailsScreen extends StatelessWidget {
  final JobApplication application;

  const ApplicationDetailsScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn ứng tuyển'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(application.image),
                  radius: 60,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Tên ứng viên: ${application.name}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Số điện thoại: ${application.phone}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Trình độ học vấn: ${application.education}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Kinh nghiệm: ${application.experience}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Xử lý khi chấp nhận hoặc từ chối ứng viên
                },
                child: const Text('Phản hồi ứng viên'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
