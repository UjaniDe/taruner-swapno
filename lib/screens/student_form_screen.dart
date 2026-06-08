import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taruner_swapno/services/auth_service.dart';
import 'confirmation_screen.dart';

class StudentProfile {
  final String studentCode;
  final String name;
  final String fatherName;
  final String motherName;
  final String guardianName;
  final String guardianMobile;
  final String gender;
  final String dob;
  final String maskedAadhar;
  final String schoolName;
  final String className;
  final String section;
  final String roll;
  final String bankName;
  final String branchName;
  final String ifsc;
  final String accountNumber;

  const StudentProfile({
    required this.studentCode,
    required this.name,
    required this.fatherName,
    required this.motherName,
    required this.guardianName,
    required this.guardianMobile,
    required this.gender,
    required this.dob,
    required this.maskedAadhar,
    required this.schoolName,
    required this.className,
    required this.section,
    required this.roll,
    required this.bankName,
    required this.branchName,
    required this.ifsc,
    required this.accountNumber,
  });
}

class StudentFormScreen extends StatefulWidget {
  final String token;
  final StudentProfile profile;

  const StudentFormScreen({
    super.key,
    required this.token,
    required this.profile,
  });

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  bool _bankDetailsCorrect = false;
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _rejectRemarksController = TextEditingController();
  final AuthService _auth = AuthService();
  bool _isVerifying = false;
  bool _isRejecting = false;

  void _verifyAadhar() async {
    final aadhar = _aadharController.text.replaceAll(' ', '');
    if (aadhar.length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 12-digit Aadhaar number')),
      );
      return;
    }
    setState(() => _isVerifying = true);
    try {
      await _auth.verifyAadhar(widget.token, aadhar);
      setState(() => _isVerifying = false);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmationScreen(
            token: widget.token,
            studentCode: widget.profile.studentCode,
          ),
        ),
      );
    } catch (e) {
      setState(() => _isVerifying = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  void _showRejectDialog() {
    final outerContext = context;
    _rejectRemarksController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Reject Profile', style: TextStyle(fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please describe what details are incorrect',
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 12),
              TextField(
                controller: _rejectRemarksController,
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'e.g. My Aadhaar number is wrong...',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: _isRejecting
                  ? null
                  : () async {
                      final remarks = _rejectRemarksController.text.trim();
                      if (remarks.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter your remarks')),
                        );
                        return;
                      }
                      setDialogState(() => _isRejecting = true);
                      try {
                        await AuthService().submitRejection(
                            widget.profile.studentCode, remarks);
                        if (!mounted) return;
                        Navigator.pop(context);
                        showDialog(
                          context: outerContext,
                          barrierDismissible: false,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.all(24),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 56, height: 56,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE6F4EA),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check_rounded,
                                      color: Color(0xFF2F855A), size: 32),
                                ),
                                const SizedBox(height: 16),
                                const Text('Rejection Submitted',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                const Text('Your rejection has been recorded successfully.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 13, color: Colors.grey)),
                                const SizedBox(height: 20),
                                const Divider(),
                                const SizedBox(height: 16),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Icon(Icons.info_outline, size: 18, color: Colors.black54),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Contact the head of institute to update Aadhaar and mobile number in Bangla Shiksha Portal.',
                                        style: TextStyle(fontSize: 13, height: 1.5),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(outerContext).popUntil((route) => route.isFirst);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('Back to Login'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } catch (e) {
                        setDialogState(() => _isRejecting = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(
                              e.toString().replaceAll('Exception: ', ''))),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isRejecting
                  ? const SizedBox(height: 16, width: 16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Submit Rejection'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _aadharController.dispose();
    _rejectRemarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: SafeArea(
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
              const SizedBox(height: 32),
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
                    const Text('Student Details',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text('Please verify your details below before proceeding',
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 24),
                    const Text('PERSONAL DETAILS',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54, letterSpacing: 0.5)),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'Student Name', value: widget.profile.name),
                    _InfoRow(label: 'Student Code', value: widget.profile.studentCode),
                    _InfoRow(label: 'Father Name', value: widget.profile.fatherName),
                    _InfoRow(label: 'Mother Name', value: widget.profile.motherName),
                    _InfoRow(label: 'Guardian Name', value: widget.profile.guardianName),
                    _InfoRow(label: 'Guardian Mobile', value: widget.profile.guardianMobile),
                    _InfoRow(label: 'Gender', value: widget.profile.gender),
                    _InfoRow(label: 'Date of Birth', value: widget.profile.dob),
                    _InfoRow(label: 'Aadhaar No.', value: widget.profile.maskedAadhar),
                    const SizedBox(height: 20),
                    const Text('ACADEMIC DETAILS',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54, letterSpacing: 0.5)),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'School Name', value: widget.profile.schoolName),
                    _InfoRow(label: 'Class', value: widget.profile.className),
                    _InfoRow(label: 'Section', value: widget.profile.section),
                    _InfoRow(label: 'Roll Number', value: widget.profile.roll),
                    const SizedBox(height: 20),
                    const Text('BANK DETAILS',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54, letterSpacing: 0.5)),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'Bank Name', value: widget.profile.bankName),
                    _InfoRow(label: 'Branch Name', value: widget.profile.branchName),
                    _InfoRow(label: 'IFSC Code', value: widget.profile.ifsc),
                    _InfoRowWithToggle(label: 'Account Number', value: widget.profile.accountNumber),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        setState(() => _bankDetailsCorrect = !_bankDetailsCorrect);
                        if (!_bankDetailsCorrect) _aadharController.clear();
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24, height: 24,
                            child: Checkbox(
                              value: _bankDetailsCorrect,
                              activeColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (val) {
                                setState(() => _bankDetailsCorrect = val ?? false);
                                if (!_bankDetailsCorrect) _aadharController.clear();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text('The bank account details shown above are correct',
                                style: TextStyle(fontSize: 14, height: 1.4)),
                          ),
                        ],
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: _bankDetailsCorrect
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                const Text('Enter Aadhaar Number',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                const Text('Your Aadhaar will be verified securely. It will not be stored.',
                                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _aadharController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 12,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: InputDecoration(
                                    hintText: '12-digit Aadhaar number',
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
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isVerifying ? null : _verifyAadhar,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: _isVerifying
                                        ? const SizedBox(height: 18, width: 18,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                        : const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text('Verify & Continue', style: TextStyle(fontSize: 15)),
                                              SizedBox(width: 8),
                                              Icon(Icons.arrow_forward, size: 18),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _showRejectDialog,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Reject Profile', style: TextStyle(fontSize: 15)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('Back'),
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
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ),
          const Text(' : ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _InfoRowWithToggle extends StatefulWidget {
  final String label;
  final String value;
  const _InfoRowWithToggle({required this.label, required this.value});

  @override
  State<_InfoRowWithToggle> createState() => _InfoRowWithToggleState();
}

class _InfoRowWithToggleState extends State<_InfoRowWithToggle> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(widget.label,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ),
          const Text(' : ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              _visible ? widget.value : '••••••••••••',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _visible = !_visible),
            child: Icon(
              _visible ? Icons.visibility_off : Icons.visibility,
              size: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}