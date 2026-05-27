import 'package:flutter/material.dart';
import 'package:taruner_swapno/services/auth_service.dart';

class RejectDetailsScreen extends StatefulWidget {
  final String studentCode;
  final String mobile;

  const RejectDetailsScreen({
    super.key,
    required this.studentCode,
    required this.mobile,
  });

  @override
  State<RejectDetailsScreen> createState() => _RejectDetailsScreenState();
}

class _RejectDetailsScreenState extends State<RejectDetailsScreen> {
  bool _wantsToReject = false;
  bool _isSubmitting = false;
  final TextEditingController _remarksController = TextEditingController();

  void _submitRejection() async {
    final remarks = _remarksController.text.trim();
    if (remarks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your remarks before rejecting')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await AuthService().submitRejection(widget.studentCode, remarks);
      setState(() => _isSubmitting = false);
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.black),
              SizedBox(width: 8),
              Text('Action Required', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: const Text(
            'Contact the head of institute to update Aadhaar and mobile number in Bangla Shiksha Portal.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  @override
  void dispose() {
    _remarksController.dispose();
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
                    const Text('Please verify your details below',
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 24),
                    const Text('PERSONAL DETAILS',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'Student Code', value: widget.studentCode),
                    _InfoRow(label: 'Mobile', value: widget.mobile),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        setState(() => _wantsToReject = !_wantsToReject);
                        if (!_wantsToReject) _remarksController.clear();
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _wantsToReject,
                              activeColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              onChanged: (val) {
                                setState(() => _wantsToReject = val ?? false);
                                if (!_wantsToReject) _remarksController.clear();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Yes, I want to continue rejecting my profile',
                              style: TextStyle(fontSize: 14, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: _wantsToReject
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                const Text('Remarks',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                const Text('Please describe what details are incorrect',
                                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _remarksController,
                                  maxLines: 4,
                                  maxLength: 500,
                                  decoration: InputDecoration(
                                    hintText: 'e.g. My Aadhaar number is wrong, correct number is...',
                                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Colors.black),
                                    ),
                                    contentPadding: const EdgeInsets.all(14),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isSubmitting ? null : _submitRejection,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: _isSubmitting
                                        ? const SizedBox(
                                            height: 18, width: 18,
                                            child: CircularProgressIndicator(
                                                color: Colors.white, strokeWidth: 2))
                                        : const Text('Reject Profile',
                                            style: TextStyle(fontSize: 15)),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),
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
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ),
          const Text(' : ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}