import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'app/app_translations.dart';
import 'app/routes/app_pages.dart';
import 'app/service/local_storage.dart';
import 'app/service/fcm_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final prefs = await SharedPreferences.getInstance();
  final storage = LoginTokenStorage(prefs);
  storage.isCattleLoggedIn.value = storage.hasValidCattleToken();
  Get.put(storage);

  // ✅ Proper Firebase initialization (Android + Web)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // ✅ Initialize FCM Service
  await FcmService.initialize();
  final token = await FcmService.getFcmToken();

  debugPrint("========== REAL FCM TOKEN ==========");
  debugPrint(token);
  debugPrint("====================================");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Application",
      translations: AppTranslations(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
