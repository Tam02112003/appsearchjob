import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyApplicationsScreen extends StatelessWidget {
  final String userId;

  MyApplicationsScreen({super.key, required this.userId});

  Future<List<Application>> fetchApplications(String userId) async {
    final url = Uri.parse('https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage/job');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Nếu yêu cầu thành công, giải mã dữ liệu JSON
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Application.fromJson(item)).toList();
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
        title: const Text('Các bài ứng tuyển của tôi'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Application>>(
        future: fetchApplications(userId),
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
                  ? const Center(child: Text('Chưa có bài ứng tuyển nào.'))
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

class Application {
  final String jobTitle;
  final String companyName;
  final String applicationDate;

  Application({
    required this.jobTitle,
    required this.companyName,
    required this.applicationDate,
  });

  // Tạo constructor từ dữ liệu JSON
  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      jobTitle: json['jobTitle'] ?? 'N/A',
      companyName: json['companyName'] ?? 'N/A',
      applicationDate: json['applicationDate'] ?? 'N/A',
    );
  }
}

class ApplicationCard extends StatelessWidget {
  final Application application;

  const ApplicationCard({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          application.jobTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Công ty: ${application.companyName}',
              style: const TextStyle(color: Colors.black54),
            ),
            Text(
              'Ngày ứng tuyển: ${application.applicationDate}',
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}