import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service to handle push notifications using Firebase Cloud Messaging
/// Note: Local notifications disabled due to build issues
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialize notification service
  Future<void> initialize() async {
    // Request permission
    await _requestPermission();
    
    // Get FCM token
    await _getFCMToken();
    
    // Listen to token refresh
    _fcm.onTokenRefresh.listen(_saveFCMToken);
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle background message taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);
    
    // Check if app was opened from a notification
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageTap(initialMessage);
    }
  }

  /// Request notification permission
  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Notification permission granted');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('⚠️ Notification permission provisional');
    } else {
      print('❌ Notification permission denied');
    }
  }

  /// Get and save FCM token
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _fcm.getToken();
      if (_fcmToken != null) {
        print('📱 FCM Token: $_fcmToken');
        await _saveFCMToken(_fcmToken!);
      }
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
  }

  /// Save FCM token to Firestore
  Future<void> _saveFCMToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Check if user is a driver
      final driverDoc = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(user.uid)
          .get();

      if (driverDoc.exists) {
        // Save to driver document
        await FirebaseFirestore.instance
            .collection('drivers')
            .doc(user.uid)
            .update({'fcmToken': token});
      } else {
        // Save to user document  
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'fcmToken': token});
      }
      
      print('✅ FCM token saved to Firestore');
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('📬 Foreground message: ${message.notification?.title}');
    print('   ${message.notification?.body}');
    // Note: Notifications will show in system tray
  }

  /// Handle notification tap
  void _handleMessageTap(RemoteMessage message) {
    print('🔔 Notification tapped: ${message.data}');
    
    // Navigate based on notification data
    final orderId = message.data['orderId'];
    if (orderId != null) {
      // TODO: Navigate to order tracking screen
      print('Navigate to order: $orderId');
    }
  }

  /// Send notification to user (logging only - requires Cloud Functions)
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    print('📤 Would send notification to user $userId: $title - $body');
    print('   Note: Requires Cloud Functions for actual delivery');
  }

  /// Send notification to driver
  Future<void> sendNotificationToDriver({
    required String driverId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    print('📤 Would send notification to driver $driverId: $title - $body');
    print('   Note: Requires Cloud Functions for actual delivery');
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔔 Background message: ${message.notification?.title}');
}
