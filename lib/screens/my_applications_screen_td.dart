import 'package:flutter/material.dart';
import '../models/application_class.dart';
import '../services/api_service.dart';

class JobApplicationsPage extends StatefulWidget {
  final String userId;

  JobApplicationsPage({required this.userId});

  @override
  _JobApplicationsPageState createState() => _JobApplicationsPageState();
}

class _JobApplicationsPageState extends State<JobApplicationsPage> {
  late Future<List<JobApplication>> _jobApplications;
  final ApiService apiService = ApiService('https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage'); // Tạo thể hiện của ApiService

  @override
  void initState() {
    super.initState();
    // Gọi hàm từ ApiService
    _jobApplications = apiService.getMyJobApplications(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Danh Sách Đơn Ứng Tuyển Của Bạn')),
      body: FutureBuilder<List<JobApplication>>(
        future: _jobApplications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Bạn không có đơn ứng nào.'));
          } else {
            final applications = snapshot.data!;
            return ListView.builder(
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final application = applications[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: application.image.isNotEmpty
                        ? Image.network(application.image, width: 50, height: 50, fit: BoxFit.cover)
                        : Icon(Icons.person, size: 50),
                    title: Text(application.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trình độ: ${application.education}'),
                        Text('Kinh nghiệm: ${application.experience}'),
                        Text('Số điện thoại: ${application.phone}'),
                      ],
                    ),
                    onTap: () {
                      // Xử lý khi nhấn vào đơn ứng tuyển
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}