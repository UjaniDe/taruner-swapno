import 'package:flutter/material.dart';
import 'package:taruner_swapno/screens/student_form_screen.dart';
import 'package:taruner_swapno/services/auth_service.dart';

class OtpScreen extends StatefulWidget {
  final String studentCode;
  const OtpScreen({super.key, required this.studentCode});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final AuthService _auth = AuthService();
  bool _isLoading = false;
  int _secondsLeft = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() { _secondsLeft = 60; _canResend = false; });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) { setState(() => _canResend = true); return false; }
      return true;
    });
  }

  void _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _auth.verifyOtp(widget.studentCode, otp);
      final token = result['token'];
      final profileData = await _auth.getProfile(token);

      setState(() => _isLoading = false);
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StudentFormScreen(
            token: token,
profile: StudentProfile(
  studentCode: profileData['studentCode'] ?? '',
  name: profileData['name'] ?? '',
  fatherName: profileData['fatherName'] ?? '',
  motherName: profileData['motherName'] ?? '',
  guardianName: profileData['guardianName'] ?? '',
  guardianMobile: profileData['guardianMobile'] ?? '',
  gender: profileData['gender'] ?? '',
  dob: profileData['dob'] ?? '',
  maskedAadhar: profileData['maskedAadhar'] ?? '',
  schoolName: profileData['schoolName'] ?? '',
  className: profileData['className'] ?? '',
  section: profileData['section'] ?? '',
  roll: profileData['roll'] ?? '',
  bankName: profileData['bankName'] ?? '',
  branchName: profileData['branchName'] ?? '',
  ifsc: profileData['ifsc'] ?? '',
  accountNumber: profileData['accountNumber'] ?? '',
),
          ),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.school, size: 28),
                    SizedBox(width: 8),
                    Text('Traruner Swapno',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Verify OTP',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(
                        'OTP sent to the mobile number registered for Student Code: ${widget.studentCode}',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      const Text('Enter OTP',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          hintText: 'Enter the OTP',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: _isLoading
                              ? const SizedBox(height: 18, width: 18,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Verify OTP', style: TextStyle(fontSize: 15)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: _canResend
                            ? TextButton(
                                onPressed: () {
                                  // TODO: call resend API
                                  _startTimer();
                                },
                                child: const Text('Resend OTP',
                                    style: TextStyle(color: Colors.black)),
                              )
                            : Text('Resend OTP in $_secondsLeft s',
                                style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back, size: 16, color: Colors.grey),
                              SizedBox(width: 4),
                              Text('Back', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}