import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/job_class.dart';
import 'ApplicationsScreen.dart';
import 'application_screen.dart';

class MyJobPostsScreen extends StatelessWidget {
  final String userId;

  MyJobPostsScreen({super.key, required this.userId});

  Future<List<JobPost>> fetchJobPosts(String userId) async {
    final url = Uri.parse(
        'https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage/job?userId=$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => JobPost.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load job posts');
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
        title: const Text('Các bài đăng tuyển của tôi'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<JobPost>>(
        future: fetchJobPosts(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var jobPosts = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: jobPosts.isEmpty
                  ? const Center(child: Text('Chưa có bài đăng tuyển nào.'))
                  : ListView.builder(
                itemCount: jobPosts.length,
                itemBuilder: (context, index) {
                  return JobPostCard(
                    jobPost: jobPosts[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ApplicationsScreen(jobId: jobPosts[index].id),
                        ),
                      );
                    },
                  );
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

class JobPostCard extends StatelessWidget {
  final JobPost jobPost;
  final VoidCallback onTap;

  const JobPostCard({super.key, required this.jobPost, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          jobPost.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Công ty: ${jobPost.company}'),
            Text('Địa điểm: ${jobPost.location}'),
            Text('Lương: \$${jobPost.salary.toStringAsFixed(2)} / giờ'),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
