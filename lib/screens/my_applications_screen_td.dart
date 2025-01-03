import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../models/application_class.dart';
import '../models/job_class.dart';
import '../services/api_service.dart';
import 'dart:io';

class JobApplicationsPage extends StatefulWidget {
  final String userId;

  JobApplicationsPage({required this.userId});

  @override
  _JobApplicationsPageState createState() => _JobApplicationsPageState();
}

class _JobApplicationsPageState extends State<JobApplicationsPage> {
  late Future<List<JobApplication>> _jobApplications;
  final ApiService apiService = ApiService(
      'https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage');
  Map<String, JobPost?> _jobPosts = {}; // Lưu thông tin job theo jobId

  @override
  void initState() {
    super.initState();
    _jobApplications = apiService.getMyJobApplications(widget.userId);
    _loadJobPosts();
  }

  Future<void> _loadJobPosts() async {
    final applications = await _jobApplications;
    for (var application in applications) {
      if (!_jobPosts.containsKey(application.jobId)) {
        try {
          final jobPost = await apiService.getJobPostById(application.jobId);
          _jobPosts[application.jobId] = jobPost;
        } catch (e) {
          _jobPosts[application.jobId] = null; // Lỗi khi tải job
          print('Error loading job post for ${application.jobId}: $e');
        }
      }
    }
    setState(() {}); // Cập nhật giao diện khi dữ liệu được tải
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

                final jobPost = _jobPosts[application.jobId];

                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: application.image != null &&
                                application.image!.isNotEmpty
                            ? _buildImage(application.image)
                            : Icon(Icons.person, size: 50),
                        title: Text(application.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Trình độ: ${application.education}'),
                            Text('Kinh nghiệm: ${application.experience}'),
                            Text('Số điện thoại: ${application.phone}'),
                            Text('Trạng thái: ${application.status}'),
                            Text(
                                'Công ty: ${jobPost?.company ?? "Đang tải..."}'), // Hiển thị tên công ty
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


  Widget _buildImage(String? imagePath) {
    // Kiểm tra xem imagePath có phải là null hay không
    if (imagePath == null || imagePath.isEmpty) {
      return Icon(Icons.person, size: 50);
    }

    Widget imageWidget;

    // Kiểm tra nếu là web hoặc imagePath bắt đầu bằng 'http'
    if (kIsWeb || imagePath.startsWith('http')) {
      imageWidget =
          Image.network(imagePath, width: 50, height: 50, fit: BoxFit.cover);
    } else {
      imageWidget =
          Image.file(File(imagePath), width: 50, height: 50, fit: BoxFit.cover);
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
                backgroundDecoration: BoxDecoration(color: Colors.black),
              ),
            ),
          ),
        );
      },
      child: imageWidget,
    );
  }
}
/*  Widget _buildImage(String imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Icon(Icons.person,
          size: 50); // Nếu không có hình ảnh, hiển thị biểu tượng mặc định
    }
    Widget imageWidget;
    if (kIsWeb) {
      imageWidget =
          Image.network(imagePath, width: 50, height: 50, fit: BoxFit.cover);
    } else {
      if (imagePath.startsWith('http')) {
        imageWidget =
            Image.network(imagePath, width: 50, height: 50, fit: BoxFit.cover);
      } else {
        imageWidget = Image.file(File(imagePath),
            width: 50, height: 50, fit: BoxFit.cover);
      }
    }

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              // Đóng dialog khi nhấn vào hình
              child: PhotoView(
                imageProvider: kIsWeb || imagePath.startsWith('http')
                    ? NetworkImage(imagePath)
                    : FileImage(File(imagePath)) as ImageProvider,
                backgroundDecoration: BoxDecoration(color: Colors.black),
              ),
            ),
          ),
        );
      },
      child: imageWidget,
    );
  }*/
