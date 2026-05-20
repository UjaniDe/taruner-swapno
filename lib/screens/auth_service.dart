import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://taruner-swapno-backend.onrender.com';
class AuthService {
  // Step 1 — Send OTP (login screen)
  Future<void> sendOtp(String studentCode) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'studentCode': studentCode}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 200) throw Exception(data['message']);
  }

  // Step 2 — Verify OTP (otp screen) → returns token + student profile
  Future<Map<String, dynamic>> verifyOtp(String studentCode, String otp) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'studentCode': studentCode, 'otp': otp}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 200) throw Exception(data['message']);
    return data; // contains { token }
  }

  // Step 3 — Get student profile (after OTP verify)
  Future<Map<String, dynamic>> getProfile(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/student/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 200) throw Exception(data['message']);
    return data;
  }

  // Step 4 — Verify Aadhaar (student form screen)
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

  // Step 5 — Submit declaration (confirmation screen)
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