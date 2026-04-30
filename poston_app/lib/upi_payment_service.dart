/*
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class UpiPaymentService {
  static const String merchantVpa = 'paytm-63925821@ptys';
  static const String merchantName = 'Poston Test'; 

  /// Launches the UPI Intent flow
  /// This will open the native Android/iOS app chooser
  static Future<bool> initiatePayment({
    required double amount,
    required String transactionId,
    required String transactionNote,
  }) async {
    // Construct the UPI URI
    // Reference: https://www.npci.org.in/PDF/npci/upi/UPI-Linking-Specs-v1.6.pdf
    final String upiUri = 'upi://pay?'
        'pa=$merchantVpa'
        '&pn=${Uri.encodeComponent(merchantName)}'
        '&mc=0000'
        '&am=${amount.toStringAsFixed(2)}'
        '&cu=INR'
        '&tn=${Uri.encodeComponent(transactionNote)}';

    final Uri uri = Uri.parse(upiUri);

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // We use LaunchMode.externalNonBrowserApplication to force 
        // the OS to show the app chooser (GPay, PhonePe, etc.)
        if (await canLaunchUrl(uri)) {
          return await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          print('No UPI apps found to handle the request.');
          return false;
        }
      } else {
        print('UPI payments are only supported on Mobile devices.');
        return false;
      }
    } catch (e) {
      print('Error launching UPI intent: $e');
      return false;
    }
  }
}
*/
