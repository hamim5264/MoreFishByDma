import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../common_widgets/common_container.dart';
import '../../../routes/app_pages.dart';
import '../../../repo/auth.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkVersionAndNavigate();
  }

  Future<void> _checkVersionAndNavigate() async {
    // 1. Give splash some minimum time
    final splashFuture = Future.delayed(const Duration(seconds: 3));

    try {
      // 2. Get Current App Version + Build Number
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = "${packageInfo.version}+${packageInfo.buildNumber}"; // e.g., "2.1.4+43"

      // 3. Get Latest Version from Server
      final authRepo = AuthRepository();
      final versionResult = await authRepo.getVersion();

      await splashFuture; // Wait for minimum splash time

      versionResult.fold(
        (l) => _proceedToMain(), // Fail safe: just proceed
        (r) {
          final latestVersion = r.results?.first.versionNumber;
          if (latestVersion != null && _shouldUpdate(currentVersion, latestVersion)) {
            Get.offAllNamed(Routes.VERSION_CHECKER);
          } else {
            _proceedToMain();
          }
        },
      );
    } catch (e) {
      await splashFuture;
      _proceedToMain();
    }
  }

  /// Returns true only if the [latest] version is higher than [current].
  bool _shouldUpdate(String current, String latest) {
    try {
      final v1 = current.split('.').map(int.parse).toList();
      final v2 = latest.split('.').map(int.parse).toList();

      for (var i = 0; i < v2.length; i++) {
        if (i >= v1.length) return true; // Server has more segments (e.g. 2.1 vs 2.1.1)
        if (v2[i] > v1[i]) return true;
        if (v2[i] < v1[i]) return false;
      }
    } catch (_) {
      // If parsing fails, fall back to simple inequality
      return current != latest;
    }
    return false;
  }

  void _proceedToMain() {
    Get.offAllNamed(Routes.DMA_TECHNOLOGIES);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xffebffff),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: CommonContainer(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CommonContainer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    "assets/icons/DMA Logo.png",
                    height: 100,
                    width: 100,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'dma_technologies'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0370c3),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Intelligent Solutions For Acquaculture',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
