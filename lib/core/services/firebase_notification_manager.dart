import 'dart:convert';
import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Top-level function for background FCM handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  developer.log("Handling background message: ${message.messageId}", name: "FCMBackground");
}

class FirebaseNotificationManager {
  static final FirebaseNotificationManager _instance = FirebaseNotificationManager._internal();
  factory FirebaseNotificationManager() => _instance;
  FirebaseNotificationManager._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

/*  static const String _prefKeyFirebaseToken = "firebaseToken";
  static const String _channelId = "default_notification_channel_id";
  static const String _channelName = "Default Notification Channel";*/
  static const String _prefKeyFirebaseToken = "firebaseToken";
  static const String _channelId = "daksh_channel_id";
  static const String _channelName = "Daksh Channel Name";
  Function()? _onNotificationTap;

  // -------------------------------------------------------------
  // 1. INITIALIZE FIREBASE & NOTIFICATIONS
  // -------------------------------------------------------------
  Future<void> initialize({
    required String baseUrl,
    required String userAuthToken,
    Function()? onNotificationTap,
  }) async {
    _onNotificationTap = onNotificationTap;

    // A. Request Notification Permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      developer.log("User denied notification permissions", name: "FCM");
      return;
    }

    // Set foreground notification options for iOS
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // B. Setup Local Notifications
    const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInitSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: darwinInitSettings,
      macOS: darwinInitSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        developer.log("Notification tapped: ${response.payload}", name: "FCM");
        _handleNotificationClick();
      },
    );


    // Request Android 13+ permission for local notifications
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // C. Create Android Notification Channel
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Default Notification Channel for Daksh App',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // D. Register Background Message Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // E. Listen to Foreground Messages (App Open)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final title = notification?.title ?? message.data['title'];
      final body = notification?.body ?? message.data['body'];

      if (title != null || body != null) {
        _showNotification(
          title: title,
          body: body,
        );
      }
    });

    // F. Sync Token with Server
    await syncFirebaseToken(baseUrl: baseUrl, userAuthToken: userAuthToken);

    // G. Listen for Token Refresh
    _fcm.onTokenRefresh.listen((newToken) async {
      await updateFirebaseToken(baseUrl: baseUrl, userAuthToken: userAuthToken, newToken: newToken);
    });
  }

  // -------------------------------------------------------------
  // 2. TOKEN SYNC LOGIC
  // -------------------------------------------------------------
  Future<void> syncFirebaseToken({
    required String baseUrl,
    required String userAuthToken,
  }) async {
    try {
      String? currentFcmToken = await _fcm.getToken();
      if (currentFcmToken == null || currentFcmToken.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      String? cachedToken = prefs.getString(_prefKeyFirebaseToken);

      // Don't resend if token hasn't changed
      if (cachedToken == currentFcmToken) return;

      await updateFirebaseToken(
        baseUrl: baseUrl,
        userAuthToken: userAuthToken,
        newToken: currentFcmToken,
      );
    } catch (e, stackTrace) {
      developer.log("Error fetching FCM token: $e", error: e, stackTrace: stackTrace, name: "FCM");
    }
  }
  // Handle Notification Click Action
  void _handleNotificationClick() {
    if (_onNotificationTap != null) {
      _onNotificationTap!();
    }
  }
  // -------------------------------------------------------------
  // 3. API CALL (@PATCH("updateFirebaseToken"))
  // -------------------------------------------------------------
  Future<bool> updateFirebaseToken({
    required String baseUrl,
    required String userAuthToken,
    required String? newToken,
  }) async {
    try {
      final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
      final uri = Uri.parse('$cleanBaseUrl/updateFirebaseToken');

      final response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userAuthToken',
        },
        body: jsonEncode({
          'token': newToken,
          'firebaseToken': newToken,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        if (newToken != null && newToken.isNotEmpty) {
          await prefs.setString(_prefKeyFirebaseToken, newToken);
        } else {
          await prefs.remove(_prefKeyFirebaseToken);
        }
        return true;
      } else {
        developer.log("Failed to update Firebase token. Status code: ${response.statusCode}", name: "FCM");
      }
    } catch (e, stackTrace) {
      developer.log("Error updating Firebase token on server: $e", error: e, stackTrace: stackTrace, name: "FCM");
    }
    return false;
  }

  // -------------------------------------------------------------
  // 4. CLEAR TOKEN ON LOGOUT
  // -------------------------------------------------------------
  Future<void> clearTokenOnLogout({
    required String baseUrl,
    required String userAuthToken,
  }) async {
    await updateFirebaseToken(
      baseUrl: baseUrl,
      userAuthToken: userAuthToken,
      newToken: null,
    );
    try {
      await _fcm.deleteToken();
    } catch (e, stackTrace) {
      developer.log("Error deleting FCM token on logout: $e", error: e, stackTrace: stackTrace, name: "FCM");
    }
  }

  // -------------------------------------------------------------
  // 5. SHOW LOCAL NOTIFICATION
  // -------------------------------------------------------------
  void _showNotification({String? title, String? body}) {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Default Notification Channel for Daksh App',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    // Unique notification ID based on timestamp
    int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    _localNotifications.show(
      id: notificationId,
      title: title ?? 'Notification',
      body: body ?? '',
      notificationDetails: details,
    );
  }
}
