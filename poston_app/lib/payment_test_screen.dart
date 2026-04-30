import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'upi_payment_service.dart';
import 'dart:math';

class PaymentTestScreen extends StatefulWidget {
  const PaymentTestScreen({super.key});

  @override
  State<PaymentTestScreen> createState() => _PaymentTestScreenState();
}

class _PaymentTestScreenState extends State<PaymentTestScreen> {
  bool _isProcessing = false;

  String _generateTxnId() {
    final random = Random();
    return 'T${DateTime.now().millisecondsSinceEpoch}${random.nextInt(1000)}';
  }

  void _startPayment() async {
    /*
    setState(() => _isProcessing = true);

    final txnId = _generateTxnId();
    
    final success = await UpiPaymentService.initiatePayment(
      amount: 1.0,
      transactionId: txnId,
      transactionNote: 'Testing Poston UPI Intent',
    );

    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open any UPI apps. Please use the Manual Copy option below.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isProcessing = false);
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Temple Pooja Payment'),
        backgroundColor: const Color(0xFFFF5722),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFFF5722),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 40, left: 24, right: 24),
              child: Column(
                children: [
                  const Text(
                    'Transaction Amount',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '₹1.00',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Test Transaction (₹1 Only)',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PAYMENT METHOD',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Main Payment Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.flash_on, color: Colors.amber),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Instant UPI Intent',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    'Open GPay, PhonePe, or Paytm automatically',
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isProcessing ? null : _startPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF5722),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: _isProcessing
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'PAY NOW',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  const Text(
                    'FALLBACK OPTION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  /*
                  // Manual Copy Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Manual UPI ID',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'paytm-63925821@ptys',
                                style: TextStyle(color: Color(0xFFFF5722), fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(const ClipboardData(text: 'paytm-63925821@ptys'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('UPI ID copied to clipboard!')),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  */
                  
                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      'Secured by NPCI Unified Payments Interface',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network('https://www.npci.org.in/images/npci/upi-logo.png', height: 20, errorBuilder: (_, __, ___) => const Text('UPI')),
                      const SizedBox(width: 12),
                      const Icon(Icons.verified_user, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      const Text('Verified Merchant', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
