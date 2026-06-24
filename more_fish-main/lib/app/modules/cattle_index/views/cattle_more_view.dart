import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../controllers/cattle_index_controller.dart';
import '../controllers/cattle_live_monitoring_controller.dart';

class CattleMoreView extends GetView<CattleIndexController> {
  const CattleMoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffebffff),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _SimpleMoreTile(
            title: 'faq_menu'.tr,
            onTap: () => Get.toNamed(Routes.FAQ),
          ),
          const SizedBox(height: 10),
          _SimpleMoreTile(
            title: 'about_app_menu'.tr,
            onTap: () => Get.toNamed(Routes.ABOUT_APP),
          ),
          const SizedBox(height: 10),
          _SimpleMoreTile(
            title: 'about_device_menu'.tr,
            onTap: () => Get.toNamed(Routes.ABOUT_DEVICES),
          ),
          const SizedBox(height: 10),
          _SimpleMoreTile(
            title: 'automation_settings_menu'.tr,
            onTap: () {
              final monitoringCtrl = Get.find<CattleLiveMonitoringController>();
              final farmId = monitoringCtrl.selectedDeviceId.value;
              if (farmId.isNotEmpty) {
                Get.toNamed(
                  Routes.CATTLE_AUTOMATION_SETTINGS,
                  arguments: {'farmId': farmId},
                );
              } else {
                Get.snackbar('Error', 'No farm selected');
              }
            },
          ),
          const SizedBox(height: 10),
          _LanguageTile(),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'language'.tr,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'bn') {
                  Get.updateLocale(const Locale('bn', 'BD'));
                } else {
                  Get.updateLocale(const Locale('en', 'US'));
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(value: 'en', child: Text('english'.tr)),
                PopupMenuItem<String>(value: 'bn', child: Text('bangla'.tr)),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xff8beeef),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (Get.locale?.languageCode ?? 'en') == 'bn'
                      ? 'bangla'.tr
                      : 'english'.tr,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleMoreTile extends StatelessWidget {
  const _SimpleMoreTile({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade700),
            ],
          ),
        ),
      ),
    );
  }
}
