import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'dart:convert';

import '../models/application_class.dart';
import 'ApplicationDetailsScreen.dart';

class ApplicationsScreen extends StatefulWidget {
  final String jobId;

  const ApplicationsScreen({super.key, required this.jobId});

  @override
  _ApplicationsScreenState createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  late Future<List<JobApplication>> futureApplications;

  @override
  void initState() {
    super.initState();
    futureApplications = fetchApplications(widget.jobId);
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                futureApplications = fetchApplications(widget.jobId);
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<JobApplication>>(
        future: futureApplications,
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
                  : ListView.separated(
                itemCount: applications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return ApplicationCard(
                    application: applications[index],
                    isDarkMode: isDarkMode,
                    onUpdate: () {
                      setState(() {
                        futureApplications = fetchApplications(widget.jobId);
                      });
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

class ApplicationCard extends StatelessWidget {
  final JobApplication application;
  final bool isDarkMode;
  final VoidCallback onUpdate; // Hàm callback để cập nhật danh sách

  const ApplicationCard({
    super.key,
    required this.application,
    required this.isDarkMode,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      child: ListTile(
        leading: _buildImage(context, application.image),
        title: Text(
          application.name ?? 'Không có tên',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trình độ học vấn: ${application.education ?? 'Không có thông tin'}', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black)),
            Text('Kinh nghiệm: ${application.experience ?? 'Không có thông tin'}', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black)),
            Text('Số điện thoại: ${application.phone ?? 'Không có thông tin'}', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black)),
            Text('Trạng thái: ${application.status ?? 'Không có thông tin'}', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black)),
          ],
        ),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ApplicationDetailsScreen(application: application),
            ),
          );

          if (result == true) {
            onUpdate(); // Gọi hàm callback để cập nhật danh sách
          }
        },
      ),
    );
  }

  Widget _buildImage(BuildContext context, String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Image.asset('assets/logo.png', width: 100);
    }

    Widget imageWidget;

    if (kIsWeb || imagePath.startsWith('http')) {
      imageWidget = Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error, size: 100);
        },
      );
    } else {
      imageWidget = Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error, size: 100);
        },
      );
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
                backgroundDecoration: const BoxDecoration(color: Colors.black),
              ),
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 120,
          height: 120,
          child: imageWidget,
        ),
      ),
    );
  }
}