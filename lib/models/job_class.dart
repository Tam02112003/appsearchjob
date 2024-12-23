class JobPost {
  final String id;
  final String title;
  final String description;
  final String company;
  final String location; // Thêm địa chỉ
  final double salary; // Thêm lương theo giờ
  final String userId; // ID của người đăng

  JobPost({
    required this.id,
    required this.title,
    required this.description,
    required this.company,
    required this.location,
    required this.salary,
    required this.userId, // Thêm userId vào constructor
  });

  factory JobPost.fromJson(Map<String, dynamic> json) {
    return JobPost(
      id: json['jobId'],
      title: json['title'],
      description: json['description'],
      company: json['company'],
      location: json['location'], // Lấy địa chỉ từ JSON
      salary: json['salary']?.toDouble() ?? 0.0, // Lấy lương theo giờ từ JSON
      userId: json['userId'], // Lấy userId từ JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobId': id,
      'title': title,
      'description': description,
      'company': company,
      'location': location, // Thêm địa chỉ vào JSON
      'salary': salary, // Thêm lương theo giờ vào JSON
      'userId': userId, // Thêm userId vào JSON
    };
  }
}