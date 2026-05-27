import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'verify_and_reject_screen.dart';

import 'package:taruner_swapno/services/auth_service.dart';

class FindStudentAccountScreen extends StatefulWidget {
  const FindStudentAccountScreen({super.key});

  @override
  State<FindStudentAccountScreen> createState() =>
      _FindStudentAccountScreenState();
}

class _FindStudentAccountScreenState extends State<FindStudentAccountScreen> {
  final TextEditingController _studentCodeCtrl = TextEditingController();
  final TextEditingController _mobileCtrl = TextEditingController();
  final TextEditingController _aadharCtrl = TextEditingController();
  bool _isLoading = false;

  void _findProfile() async {
    final code = _studentCodeCtrl.text.trim();
    final mobile = _mobileCtrl.text.trim();
    final aadhar = _aadharCtrl.text.trim();

    if (code.isEmpty || mobile.isEmpty || aadhar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
      );
      return;
    }

    if (aadhar.length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 12-digit Aadhaar number')),
      );
      return;
    }

setState(() => _isLoading = true);

try {
  await AuthService().findStudentAccount(code, mobile, aadhar);
  setState(() => _isLoading = false);
  if (!mounted) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => VerifyAndRejectScreen(studentCode: code),
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
    _studentCodeCtrl.dispose();
    _mobileCtrl.dispose();
    _aadharCtrl.dispose();
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
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.school, size: 28),
                    SizedBox(width: 8),
                    Text('Traruner Swapno',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 40),

                // Card
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
                      const Text('Find Your Student Account',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text(
                        'Please enter your student code, mobile number and Aadhaar number to search for your account.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),

                      // Student Code
                      const Text('Student Code (Banglar Shiksha ID)',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _studentCodeCtrl,
                        decoration: InputDecoration(
                          hintText: 'Enter your Student Code',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Guardian Mobile
                      const Text("Guardian's Mobile Number",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      const Text(
                          '(That is tagged with your student profile in Banglar Shiksha Portal)',
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _mobileCtrl,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          hintText: 'Enter your Guardian Mobile Number',
                          hintStyle: const TextStyle(color: Colors.grey),
                          counterText: '',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Aadhaar
                      const Text('Aadhaar Number',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      const Text(
                          '(That is tagged with your student profile in Banglar Shiksha Portal)',
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _aadharCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 12,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          hintText: 'Enter your Aadhaar Number',
                          hintStyle: const TextStyle(color: Colors.grey),
                          counterText: '',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Find button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _findProfile,
                          icon: _isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.search, size: 18),
                          label: Text(
                            _isLoading ? '' : 'Find Student Profile',
                            style: const TextStyle(fontSize: 15),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A4A4A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 4),

                      // Back to login
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text('Back to Login'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}