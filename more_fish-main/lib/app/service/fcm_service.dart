
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../firebase_options.dart';
import '../repo/auth.dart';
import '../routes/app_pages.dart';
import 'local_storage.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'more_fish_notifications',
  'More Fish Notifications',
  description: 'More Fish Push Notifications',
  importance: Importance.max,
);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
    ) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final pharmaToken = prefs.getString('pharmaToken');
  final poultryToken = prefs.getString('poultryToken');
  final cattleToken = prefs.getString('cattleToken');

  bool isLoggedIn = (token != null && token.isNotEmpty && token != 'null') ||
      (pharmaToken != null && pharmaToken.isNotEmpty && pharmaToken != 'null') ||
      (poultryToken != null && poultryToken.isNotEmpty && poultryToken != 'null') ||
      (cattleToken != null && cattleToken.isNotEmpty && cattleToken != 'null');

  if (!isLoggedIn) {
    debugPrint("User not logged in. Ignoring background message.");
    return;
  }

  debugPrint(
    "Handling a background message: ${message.messageId}",
  );

  final title =
      message.data['title'] ??
          message.notification?.title ??
          'New Alert';

  final body =
      message.data['message'] ??
          message.notification?.body ??
          '';

  await flutterLocalNotificationsPlugin.show(
    //DateTime.now().millisecondsSinceEpoch ~/ 1000,
    DateTime.now().microsecondsSinceEpoch.remainder(1000000),
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );
}

class FcmService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;


  static bool _isUserLoggedIn() {
    final storage = Get.find<LoginTokenStorage>();

    return storage.hasValidMoreFishToken() ||
        storage.hasValidPoultryToken() ||
        storage.hasValidCattleToken() ||
        storage.hasValidPharmaToken();
  }

  static Future<void> initialize() async {
    await _initializeLocalNotifications();

    NotificationSettings settings =
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else {
      debugPrint(
        'User declined or has not accepted permission',
      );
    }

    await _firebaseMessaging
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final currentToken = await _firebaseMessaging.getToken();

    if (currentToken != null) {
      debugPrint("====================================");
      debugPrint("Initial FCM Token: $currentToken");
      debugPrint("====================================");

      _updateTokenOnServer(currentToken);
    }

    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );

    FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) async {

            if (!_isUserLoggedIn()) {
              debugPrint(
                'User not logged in. Ignoring notification.',
              );
              return;
            }
        debugPrint(
          'Got a message whilst in the foreground!',
        );

        debugPrint(
          'Message data: ${message.data}',
        );

        final title =
            message.data['title'] ??
                message.notification?.title ??
                'New Alert';

        final body =
            message.data['message'] ??
                message.notification?.body ??
                '';

        _incrementUnreadCount();

        await _showLocalNotification(
          title,
          body,
        );

        // Get.snackbar(
        //   title,
        //   body,
        //   snackPosition: SnackPosition.TOP,
        //   backgroundColor:
        //   const Color(0xffd4fcfd).withOpacity(0.9),
        //   colorText: Colors.black,
        //   duration: const Duration(seconds: 6),
        //   onTap: (_) =>
        //       _handleMessageNavigation(message),
        // );
            if (Get.overlayContext != null) {
              Get.snackbar(
                title,
                body,
                snackPosition: SnackPosition.TOP,
                backgroundColor: const Color(0xffd4fcfd).withOpacity(0.9),
                colorText: Colors.black,
                duration: const Duration(seconds: 6),
                onTap: (_) => _handleMessageNavigation(message),
              );
            }
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
          (RemoteMessage message) {

            if (!_isUserLoggedIn()) {
              return;
            }
        debugPrint(
          'A new onMessageOpenedApp event was published!',
        );

        _handleMessageNavigation(message);
      },
    );

    final initialMessage =
    await _firebaseMessaging.getInitialMessage();

    // if (initialMessage != null) {
    //   Future.delayed(
    //     const Duration(seconds: 1),
    //         () {
    //       _handleMessageNavigation(
    //         initialMessage,
    //       );
    //     },
    //   );
    // }
    if (
    initialMessage != null &&
        _isUserLoggedIn()
    ) {
      Future.delayed(
        const Duration(seconds: 1),
            () {
          _handleMessageNavigation(
            initialMessage,
          );
        },
      );
    }

    _firebaseMessaging.onTokenRefresh.listen(
          (newToken) {
        debugPrint(
          "FCM Token Refreshed: $newToken",
        );

        _updateTokenOnServer(newToken);
      },
    );
  }

  static Future<void>
  _initializeLocalNotifications() async {
    const androidSettings =
    AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );

    const settings =
    InitializationSettings(
      android: androidSettings,
    );

    await flutterLocalNotificationsPlugin
        .initialize(settings);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
    >()
        ?.createNotificationChannel(channel);
  }

  static Future<void> _showLocalNotification(
      String title,
      String body,
      ) async {
    await flutterLocalNotificationsPlugin.show(
      //DateTime.now().millisecondsSinceEpoch ~/ 1000,
      DateTime.now().microsecondsSinceEpoch.remainder(1000000),
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription:
          channel.description,
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  static void _incrementUnreadCount() {
    final storage =
    Get.find<LoginTokenStorage>();

    storage
        .unreadNotificationCount
        .value++;
  }

  static Future<void> clearFcmTokenOnLogout() async {
    debugPrint("Clearing FCM token on server before logout");
    _updateTokenOnServer("");
  }

  static void _updateTokenOnServer(
      String token,
      ) {
    debugPrint("Sending token to backend: $token");
    final storage =
    Get.find<LoginTokenStorage>();

    final authRepo = AuthRepository();

    if (storage.hasValidMoreFishToken()) {
      authRepo.updateFcmToken(
        fcmToken: token,
        isPoultryFlow: false,
      );
    }

    if (storage.hasValidPoultryToken()) {
      authRepo.updateFcmToken(
        fcmToken: token,
        isPoultryFlow: true,
      );
    }

    if (storage.hasValidCattleToken()) {
      authRepo.updateFcmToken(
        fcmToken: token,
        isCattleFlow: true,
      );
    }

    if (storage.hasValidPharmaToken()) {
      authRepo.updateFcmToken(
        fcmToken: token,
        isPharmaFlow: true,
      );
    }
  }

  static void _handleMessageNavigation(
      RemoteMessage message,
      ) {
    debugPrint(
      "Navigating from notification data: ${message.data}",
    );

    final type = message.data['type']
        ?.toString()
        .toLowerCase();

    if (type == 'cattle') {
      Get.toNamed(
        Routes.CATTLE_INDEX,
      );
    } else if (type == 'poultry') {
      Get.toNamed(
        Routes.POULTRY_INDEX,
      );
    } else if (type == 'pharma' ||
        type == 'clean_air') {
      Get.toNamed(
        Routes.CLEAN_AIR_INDEX,
      );
    } else {
      Get.toNamed(
        Routes.NOTIFICATIONS,
      );
    }
  }

  static Future<String?> getFcmToken() async {
    try {
      final token =
      await _firebaseMessaging.getToken();

      debugPrint(
        'FCM Token: $token',
      );

      return token;
    } catch (e) {
      debugPrint(
        'Error getting FCM token: $e',
      );

      return null;
    }
  }
}