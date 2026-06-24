import 'package:get/get.dart';
import '../../water_quality_device/controllers/water_quality_device_controller.dart';
import '../../../routes/app_pages.dart';
import 'package:flutter/material.dart';
import '../../../../app/service/local_storage.dart';
import '../../../../app/response/pond_data_response.dart';

class MoreController extends GetxController {
  var items = [
    "faq_menu",
    "about_app_menu",
    "about_device_menu",
    "automation_settings_menu",
  ];

  void navigateToItem(int index) {
    switch (index) {
      case 0:
        Get.toNamed(Routes.FAQ);
        break;
      case 1:
        Get.toNamed(Routes.ABOUT_APP);
        break;
      case 2:
        Get.toNamed(Routes.ABOUT_DEVICES);
        break;
      case 3:
        _handleAutomationNavigation();
        break;
    }
  }

  void _handleAutomationNavigation() {
    String? deviceId;

    if (Get.isRegistered<WaterQualityDeviceController>()) {
      final wqController = Get.find<WaterQualityDeviceController>();
      final data = wqController.pondDataResponse.value?.data;
      if (data != null && data.devices.isNotEmpty) {
        deviceId = data.devices.first.deviceId;
      }
    }

    if (deviceId == null) {
      try {
        final storage = Get.find<LoginTokenStorage>();
        final prefs = storage.sharedPreferences;
        final cachedDataStr = prefs.getString('morefish_pond_data_cache');
        if (cachedDataStr != null && cachedDataStr.isNotEmpty) {
          final cachedData = PondDataResponse.fromRawJson(cachedDataStr);
          if (cachedData.data.devices.isNotEmpty) {
            deviceId = cachedData.data.devices.first.deviceId;
          }
        }
      } catch (e) {
        debugPrint('Error reading deviceId from cache: $e');
      }
    }

    if (deviceId != null) {
      Get.toNamed(
        Routes.AUTOMATION_SETTINGS,
        arguments: {'deviceId': deviceId},
      );
    } else {
      debugPrint('Automation error: Device ID is null and not found in cache');
    }
  }
}
