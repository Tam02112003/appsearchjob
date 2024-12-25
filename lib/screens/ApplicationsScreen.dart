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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách đơn ứng tuyển'),
        backgroundColor: isDarkMode ? Colors.blueGrey[900] : Colors.blueAccent,
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
                  return ApplicationCard(application: applications[index], isDarkMode: isDarkMode);
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
  final bool isDarkMode;

  const ApplicationCard({super.key, required this.application, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(application.image),
          radius: 30,
        ),
        title: Text(
          application.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trình độ học vấn: ${application.education}', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black)),
            Text('Kinh nghiệm: ${application.experience}', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black)),
            Text('Số điện thoại: ${application.phone}', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black)),
          ],
        ),
        onTap: () {
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