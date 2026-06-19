import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://taruner-swapno-backend.onrender.com';

class AuthService {
Future<bool> sendOtp(String studentCode) async {
  final res = await http.post(
    Uri.parse('$baseUrl/auth/send-otp'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'studentCode': studentCode}),
  );
  final data = jsonDecode(res.body);
  if (res.statusCode == 403 && data['alreadySubmitted'] == true) return true;
  if (res.statusCode != 200) throw Exception(data['message']);
  return false;
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

  // Find student account
Future<void> findStudentAccount(String studentCode, String mobile, String aadhar) async {
  final res = await http.post(
    Uri.parse('$baseUrl/student/find-account'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'studentCode': studentCode, 'mobile': mobile, 'aadhar': aadhar}),
  );
  final data = jsonDecode(res.body);
  if (res.statusCode != 200) throw Exception(data['message']);
}

// Verify and send OTP for reject flow
Future<void> verifyAndSendOtp(String studentCode, String aadhar, String mobile) async {
  final res = await http.post(
    Uri.parse('$baseUrl/student/verify-and-send-otp'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'studentCode': studentCode, 'aadhar': aadhar, 'mobile': mobile}),
  );
  final data = jsonDecode(res.body);
  if (res.statusCode != 200) throw Exception(data['message']);
}

// Submit rejection
Future<void> submitRejection(String studentCode, String remarks) async {
  final res = await http.post(
    Uri.parse('$baseUrl/student/reject'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'studentCode': studentCode, 'remarks': remarks}),
  );
  final data = jsonDecode(res.body);
  if (res.statusCode != 201) throw Exception(data['message']);
}
}
