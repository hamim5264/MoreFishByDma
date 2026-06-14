import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../common_widgets/common_app_bar.dart';
import '../../../routes/app_pages.dart';
import '../controllers/poultry_live_monitoring_controller.dart';
import '../controllers/poultry_header_controller.dart';
import '../controllers/poultry_index_controller.dart';

class PoultryMoreView extends GetView<PoultryIndexController> {
  const PoultryMoreView({super.key});

  void _handleAutomationNavigation() {
    if (Get.isRegistered<PoultryLiveMonitoringController>()) {
      final ctrl = Get.find<PoultryLiveMonitoringController>();
      final farmId = ctrl.selectedDeviceId.value;

      if (farmId.isNotEmpty) {
        Get.toNamed(Routes.POULTRY_AUTOMATION_SETTINGS,
            arguments: {'farmId': farmId});
      } else {
        debugPrint('Automation error: Farm ID is null');
      }
    } else {
      debugPrint('Automation error: PoultryLiveMonitoringController not registered');
    }
  }

  @override
  Widget build(BuildContext context) {
    final header = Get.find<PoultryHeaderController>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xffdbcc68),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xffebffff),
          body: Column(
            children: [
              Obx(
                () => CommonAppBar(
                  title: 'poultry_care'.tr,
                  cityName: 'dhaka'.tr,
                  date: header.formattedDate.value,
                  time: header.formattedTime.value,
                  temp: header.tempText.value,
                  humidity: header.humidityText.value,
                  logoAssetPath: 'assets/icons/dma_poultry_pulse.png',
                  backgroundColor: const Color(0xffdbcc68),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                      onTap: _handleAutomationNavigation,
                    ),
                    const SizedBox(height: 10),
                    _LanguageTile(),
                  ],
                ),
              ),
            ],
          ),
        ),
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
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
