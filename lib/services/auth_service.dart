import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://10.0.2.2:3000';

class AuthService {
  Future<void> sendOtp(String studentCode) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'studentCode': studentCode}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 200) throw Exception(data['message']);
  }

  Future<Map<String, dynamic>> verifyOtp(String studentCode, String otp) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'studentCode': studentCode, 'otp': otp}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 200) throw Exception(data['message']);
    return data;
  }

  Future<Map<String, dynamic>> getProfile(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/student/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 200) throw Exception(data['message']);
    return data;
  }

  Future<void> verifyAadhar(String token, String aadhar) async {
    final res = await http.post(
      Uri.parse('$baseUrl/student/verify-aadhar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'aadhar': aadhar}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 200) throw Exception(data['message']);
  }

  Future<String> submitDeclaration(String token, String otp) async {
    final res = await http.post(
      Uri.parse('$baseUrl/student/submit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'otp': otp}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 201) throw Exception(data['message']);
    return data['applicationNumber'];
  }
}
