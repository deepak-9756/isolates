import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<void> fetchUsers() async {
    try {
      // Making a GET request to the API
      final response = await _dio.get('https://dummyjson.com/users');

      // Checking if the request was successful
      if (response.statusCode == 200) {
        // Parse and print the data
        print('Users: ${response.data}');
      } else {
        print('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      // Handling errors
      print('Error: $e');
    }
  }
}
