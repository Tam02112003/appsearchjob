import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/application_class.dart';
import 'ApplicationDetailsScreen.dart';

class ApplicationsScreen extends StatelessWidget {
  final String jobId;

  ApplicationsScreen({super.key, required this.jobId});

  Future<List<JobApplication>> fetchApplications(String jobId) async {
    final url = Uri.parse(
        'https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage/applications?jobId=$jobId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => JobApplication.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load applications');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách đơn ứng tuyển'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<JobApplication>>(
        future: fetchApplications(jobId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var applications = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: applications.isEmpty
                  ? const Center(child: Text('Chưa có đơn ứng tuyển nào.'))
                  : ListView.builder(
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  return ApplicationCard(application: applications[index]);
                },
              ),
            );
          } else {
            return const Center(child: Text('Không có dữ liệu.'));
          }
        },
      ),
    );
  }
}

class ApplicationCard extends StatelessWidget {
  final JobApplication application;

  const ApplicationCard({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(application.image),
          radius: 30,
        ),
        title: Text(
          application.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trình độ học vấn: ${application.education}'),
            Text('Kinh nghiệm: ${application.experience}'),
            Text('Số điện thoại: ${application.phone}'),
          ],
        ),
        onTap: () {
          // Xử lý khi nhấn vào ứng viên, ví dụ hiển thị chi tiết
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ApplicationDetailsScreen(application: application),
            ),
          );
        },
      ),
    );
  }
}
