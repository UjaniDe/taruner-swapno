import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taruner_swapno/services/auth_service.dart';
import 'reject_details_screen.dart';

class VerifyAndRejectScreen extends StatefulWidget {
  final String studentCode;
  const VerifyAndRejectScreen({super.key, required this.studentCode});

  @override
  State<VerifyAndRejectScreen> createState() => _VerifyAndRejectScreenState();
}

class _VerifyAndRejectScreenState extends State<VerifyAndRejectScreen> {
  final TextEditingController _aadharCtrl = TextEditingController();
  final TextEditingController _mobileCtrl = TextEditingController();
  bool _isLoading = false;

  void _sendOtp() async {
    final aadhar = _aadharCtrl.text.trim();
    final mobile = _mobileCtrl.text.trim();

    if (aadhar.length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 12-digit Aadhaar number')),
      );
      return;
    }

    if (mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService().verifyAndSendOtp(widget.studentCode, aadhar, mobile);
      setState(() => _isLoading = false);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RejectDetailsScreen(
            studentCode: widget.studentCode,
            mobile: mobile,
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
    _aadharCtrl.dispose();
    _mobileCtrl.dispose();
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
                      const Text('Verify Your Details & Reject',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text(
                        'Please enter your correct mobile number and Aadhaar number.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      const Text('Aadhaar Number',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      const Text('(Please enter your correct 12 digit Aadhaar number)',
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _aadharCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 12,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          hintText: 'Enter your Aadhaar Number',
                          hintStyle: const TextStyle(color: Colors.grey),
                          counterText: '',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text("Guardian's Mobile Number",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      const Text('(Please enter your correct phone number)',
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _mobileCtrl,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          hintText: 'Enter your Guardian Mobile Number',
                          hintStyle: const TextStyle(color: Colors.grey),
                          counterText: '',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 18, width: 18,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Send OTP', style: TextStyle(fontSize: 15)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text('Back to Login'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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