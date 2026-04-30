import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'dart:convert';
import 'package:http/http.dart' as _http;

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  static Future<void> initialize() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings);
    
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(settings: initSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'premium_notifs',
      'Premium Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.show(
      id: message.hashCode,
      title: message.notification?.title,
      body: message.notification?.body,
      notificationDetails: platformDetails,
    );
  }

  static Future<void> updateTokenInSupabase() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.email == null) return;
    
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await Supabase.instance.client.from('user_roles').upsert({
          'email': user.email,
          'fcm_token': token,
        });
      }
    } catch (e) {
      print('Error saving token: $e');
    }
  }

  static Future<String> _getAccessToken() async {
    final accountCredentials = ServiceAccountCredentials.fromJson({
      "type": "service_account",
      "project_id": _projectId,
      "private_key_id": _privateKeyId,
      "private_key": _privateKey,
      "client_email": _clientEmail,
      "client_id": _clientId,
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40poston-53a48.iam.gserviceaccount.com"
    });
    
    const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final client = await clientViaServiceAccount(accountCredentials, scopes);
    final access = client.credentials.accessToken.data;
    client.close();
    return access;
  }

  static Future<void> sendToTokens({
    required List<String> tokens,
    required String title,
    required String body,
  }) async {
    final String accessToken = await _getAccessToken();
    final String fcmUrl = 'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';
    for (String token in tokens) {
      try {
        await _http.post(
          Uri.parse(fcmUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            'message': {
              'token': token,
              'notification': {'title': title, 'body': body},
            }
          }),
        );
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  static const String _projectId = 'poston-53a48';
  static const String _privateKeyId = 'c377f497ea2c1044d93ddc1f8ea59fe8445edb08';
  static const String _clientEmail = 'firebase-adminsdk-fbsvc@poston-53a48.iam.gserviceaccount.com';
  static const String _clientId = '112522716064354507045';
  static const String _privateKey = """-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDv8yO14vuFm3Nf\nRvtK6lFs+J39ENArmjEBdvvjN2S9WYpJeabVRuF9OF5thrZFCOTO1HxUTB6ju22m\no1EaEKG5qmFi/VqTL51n9ZWQg9Y41O35VeoVs/onAjmcTf5r/yAY6hPeFiSAEopn\nGnolqlnw8nfB/6mzQBnuEiPMdmEBu0TCHMlqPb26NSjOC3f8Wz04zmzC1V7a7qiL\n2khhsJ8PeKRLCeFAOr+NqySiIzguR5F15gw2z5Ml1dzYy3lCXg2xd3NKyiJHyxQo\niRBSW+jotQKUta32vmARnddzb0YA+tTg99xnbwzgbEUQ3SBXcCdmC9EHmNT+ltcx\nleRf/uAhAgMBAAECggEAYDpPb3Gkchv55FNYkt4uoneAEI2uFlZjYdWARcqgvWkL\n0tSVKgIfivLQt7bnIP9kl2fSppHSVdJkMohbjYru+MESBjtZmB5nz1nHTen5Pthx\nyWUBmAuR/hPf28XRiykJC8TQC+gwYiZNV/Tf2HwdTspGacgom8jQvU+MCMLOu3zC\nV0FX8Mv5v1fUZxIwfTqje1/Z9cbL/5G8GyWCVyY07xGwPE3EdNmCSEdyjt85+la/\n36rgtdT4DNGb3NYt6NG75tdzqX9GCD0dbwB43sVZzeLRWtFObWiCK5oXys3lPlRl\nShP4dCATiVWd7dvbeJbKlf1rwIvPFQcvnLege4by0wKBgQD4WesPN2+SB/G9JB2g\nj14854nfknnAMq5UizjLtgm4bbce2K045YGjusklusxDA4Y99fDse3Mt/ZgCBEsH\nGvp4Ml7khNnNWrQBw3kNv5zq4FqNSCBKUIyE1navG5VMGOpH9O1nS4XLvF/yrE2S\n72GH+CznhQewGILEoPvM8a7eIwKBgQD3Vvs2tmXds9XunRcmTbw3X97BzMywBokK\n9MGYmW6mVVPLKIVB9Af9SPjjFkpFuoPm0XFN89khf4SqSOwqpnH6XxI4uko9T4O/\ncLBDkWoTUVsahJ44qb7nu1BEhJ77xQNDdfYV1Al6jlaAZsYdS7/K6r8ZEAZqlmPl\n4JARGSOS6wKBgQDW5sgWZLvwu1sddhEFDMpZHWoawl8ER1a+5bIB5MXIh3f8Azbx\nkvd5PHouYdO68WPKXfVaTQC//T76D8j0nw250Kx4RdVKc4BsPj+T/AjG3di9hHoc\nlFLj58jPgajRLoYcOf7scVeXkqvcC+kcinP0+nWw6VZbtPoDN+Jr136fzQKBgQC2\nlLTYzIghwnD3tWqzUcrQraqIMSAgCJL9TXPjq89sZax3WbAU4YlMRaPELl4hXu+j\YZRcUNdFzRYnhbEgQsH8alXPHmVTIPFGTm8vUZaWMAYqax9JALT15uX3zlZ10Bb6\no4dG0cE1gQEFw9gXJCWuKt9qJtQ1tlKEDOMMXBxQhQKBgQCsaMqMb9teMiKsq1f0\newqHHxPSEbKn+r7/iRIr2dMi8KUg5AvOPQellzgE810sAndZg4L2//JsJ1qYopw0\nWd8JIvWY0JEwu4cutZG982ELbNU4Z/b055CX+xjFJPqJf7W8iwRUdDSn5wne0JSE\n7JL764fdOX7PLm1XVuq/R1afrw==\n-----END PRIVATE KEY-----\n""";
}
