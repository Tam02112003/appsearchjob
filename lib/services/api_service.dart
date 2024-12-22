import 'dart:convert';
import 'package:http/http.dart' as http;

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
    itemToUpdate.remove('jobId'); // Chỉ cần chắc chắn rằng jobId không có trong item

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


}