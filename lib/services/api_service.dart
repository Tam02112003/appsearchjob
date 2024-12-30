import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/application_class.dart';

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<List<dynamic>> fetchItems() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load items');
    }
  }

  Future<List<dynamic>> getMyJobs(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl?userId=$userId'));

    if (response.statusCode == 200) {
      return json.decode(response.body)['body'];
    } else {
      throw Exception('Failed to load jobs');
    }
  }

  // Hàm mới để lấy các đơn ứng tuyển của một người dùng
  Future<List<JobApplication>> getApplicationsByUserId(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/applications?userId=$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body)['body'];
      return jsonList.map((json) => JobApplication.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load applications');
    }
  }


  Future<void> createItem(Map<String, dynamic> item) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(item),
    );

    if (response.statusCode != 201) {
      print('Error: ${response.body}'); // In ra thông báo lỗi
      throw Exception('Failed to create item');
    }
  }

  Future<void> updateItem(String id, Map<String, dynamic> item) async {
    // Tạo một bản sao của item để tránh thay đổi dữ liệu gốc
    final itemToUpdate = Map<String, dynamic>.from(item);

    // Xóa khóa chính (jobId) nếu có trong item
    itemToUpdate.remove(
        'jobId'); // Chỉ cần chắc chắn rằng jobId không có trong item

    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(itemToUpdate), // Gửi dữ liệu đã loại bỏ jobId
    );

    if (response.statusCode != 200) {
      print('Error: ${response.body}'); // In ra thông báo lỗi
      throw Exception('Failed to update item');
    }
  }

  Future<void> deleteItem(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete item');
    }
  }

// Hàm gửi đơn ứng tuyển với jobId được thêm vào URL
  Future<void> sendApplication(JobApplication application) async {
    final url = Uri.parse('$baseUrl/applications/${application.jobId}'); // Thêm jobId vào URL
    final body = jsonEncode(application.toJson());

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );

    if (response.statusCode != 201) {
      print('Error: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to send application');
    }
  }

  Future<void> hideJobPost(String jobId) async {
    // Gửi yêu cầu ẩn bài viết đến server
    final response = await http.post(
      Uri.parse('https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage/hide-job-post'),
      body: jsonEncode({'jobId': jobId}),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer your_token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to hide job post');
    }
  }

  Future<void> restoreJobPost(String jobId) async {
    final response = await http.post(
      Uri.parse('https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage/restore-job-post'),
      body: jsonEncode({'jobId': jobId}),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer your_token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to restore job post');
    }
  }
}

