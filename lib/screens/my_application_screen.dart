import 'package:flutter/material.dart';

class MyApplicationsScreen extends StatelessWidget {
  final List<Application> applications = [
    Application(
      jobTitle: '[HCM, FCO] Cộng tác viên Marketing',
      companyName: 'Garena',
      applicationDate: '01/12/2024',
    ),
    Application(
      jobTitle: 'Voice Over Artist',
      companyName: 'Truelancer.com',
      applicationDate: '05/12/2024',
    ),
    Application(
      jobTitle: 'Giáo viên Tiếng Anh',
      companyName: 'DataAnnotation',
      applicationDate: '10/12/2024',
    ),
  ];

  MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Các bài ứng tuyển của tôi'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: applications.isEmpty
            ? const Center(child: Text('Chưa có bài ứng tuyển nào.'))
            : ListView.builder(
          itemCount: applications.length,
          itemBuilder: (context, index) {
            return ApplicationCard(application: applications[index]);
          },
        ),
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