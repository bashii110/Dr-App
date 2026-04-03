import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseURL = 'http://192.168.100.21:8000';

  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String type,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseURL/api/register'), // Make sure this matches your Laravel route
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'type': type,
        }),
      );


      print('Response: ${response.body}');

      final data = jsonDecode(response.body);

      // Return consistent format
      return {
        'status': response.statusCode,
        'message': data['message'] ?? (response.statusCode == 200 ? 'Success' : 'Error'),
        'data': data,
      };

    } catch (e) {
      print('API Error: $e'); // For debugging
      return {
        'status': 500,
        'message': 'Connection failed: $e',
      };
    }
  }
}