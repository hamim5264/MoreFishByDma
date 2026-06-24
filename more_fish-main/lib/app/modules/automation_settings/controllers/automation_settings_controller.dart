import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/repo/devices_repo.dart';

class AutomationSettingsController extends GetxController {
  final DevicesRepository devicesRepository = DevicesRepository();

  final isLoading = false.obs;
  final isSaving = false.obs;
  final isAutomationEnabled = false.obs;

  bool? _originalEnabled;
  String _originalMin = "";
  String _originalMax = "";

  final doMinController = TextEditingController();
  final doMaxController = TextEditingController();

  dynamic deviceId;

  bool get hasUnsavedChanges {
    return isAutomationEnabled.value != _originalEnabled ||
        doMinController.text != _originalMin ||
        doMaxController.text != _originalMax;
  }

  @override
  void onInit() {
    super.onInit();
    deviceId = Get.arguments['deviceId'];
    if (deviceId != null) {
      fetchAutomationSettings();
    }
  }

  Future<void> fetchAutomationSettings() async {
    isLoading.value = true;

    final response = await devicesRepository.getAutomationSettings(
      deviceId: deviceId,
    );

    response.fold(
      (l) {
        debugPrint('Fetch Error: ${l.message}');
      },
      (r) {
        if (r.data != null) {
          isAutomationEnabled.value = r.data!.isEnabled ?? false;
          doMinController.text = r.data!.doMin?.toString() ?? '';
          doMaxController.text = r.data!.doMax?.toString() ?? '';

          _originalEnabled = isAutomationEnabled.value;
          _originalMin = doMinController.text;
          _originalMax = doMaxController.text;
        }
      },
    );

    isLoading.value = false;
  }

  Future<void> saveSettings() async {
    if (doMinController.text.isEmpty || doMaxController.text.isEmpty) {
      _showSnackbar(
        'Error',
        'Please enter both Min and Max DO values',
        Colors.redAccent,
      );
      return;
    }

    final doMin = double.tryParse(doMinController.text);
    final doMax = double.tryParse(doMaxController.text);

    if (doMin == null || doMax == null) {
      _showSnackbar(
        'Error',
        'Please enter valid numeric values',
        Colors.redAccent,
      );
      return;
    }

    isSaving.value = true;

    final response = await devicesRepository.saveAutomationSettings(
      deviceId: deviceId,
      isEnabled: isAutomationEnabled.value,
      doMin: doMin,
      doMax: doMax,
    );

    response.fold(
      (l) {
        _showSnackbar('Error', l.message, Colors.redAccent);
      },
      (r) {
        _showSnackbar(
          'Success',
          r.message ?? 'Settings saved successfully',
          Colors.green,
        );

        if (r.data != null) {
          isAutomationEnabled.value = r.data!.isEnabled ?? false;
          doMinController.text = r.data!.doMin?.toString() ?? '';
          doMaxController.text = r.data!.doMax?.toString() ?? '';

          _originalEnabled = isAutomationEnabled.value;
          _originalMin = doMinController.text;
          _originalMax = doMaxController.text;
        }
      },
    );

    isSaving.value = false;
  }

  void _showSnackbar(String title, String message, Color color) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    doMinController.dispose();
    doMaxController.dispose();
    super.onClose();
  }
}
