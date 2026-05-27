import 'package:flutter/material.dart';
import 'package:taruner_swapno/services/auth_service.dart';
import 'reject_details_screen.dart';

class RejectOtpScreen extends StatefulWidget {
  final String studentCode;
  final String mobile;

  const RejectOtpScreen({
    super.key,
    required this.studentCode,
    required this.mobile,
  });

  @override
  State<RejectOtpScreen> createState() => _RejectOtpScreenState();
}

class _RejectOtpScreenState extends State<RejectOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
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
      // TODO: replace with real API call when NIC provides SMS
      // For now OTP is hardcoded to 123456
      await AuthService().verifyOtp(widget.studentCode, otp);

      setState(() => _isLoading = false);
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RejectDetailsScreen(
            studentCode: widget.studentCode,
            mobile: widget.mobile,
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
                        'OTP sent to ${widget.mobile} registered for Student Code: ${widget.studentCode}',
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
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
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
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Verify OTP',
                                  style: TextStyle(fontSize: 15)),
                        ),
                      ),
const SizedBox(height: 12),
                      Center(
                        child: _canResend
                            ? TextButton(
                                onPressed: () { _startTimer(); },
                                child: const Text('Resend OTP', style: TextStyle(color: Colors.black)),
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