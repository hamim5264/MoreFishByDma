import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common_widgets/common_app_bar.dart';
import '../../../common_widgets/common_container.dart';
import '../../../common_widgets/common_text.dart';
import '../../../common_widgets/common_switch.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/automation_settings_controller.dart';

class AutomationSettingsView extends GetView<AutomationSettingsController> {
  const AutomationSettingsView({super.key});

  String _toBanglaNumber(String input) {
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const banglaDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

    String result = input;
    for (int i = 0; i < englishDigits.length; i++) {
      result = result.replaceAll(englishDigits[i], banglaDigits[i]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (controller.hasUnsavedChanges) {
          _showUnsavedDialog(context);
        } else {
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: Column(
          children: [
            Obx(() {
              final weather = homeController.weatherData;
              final main = (weather.isNotEmpty) ? weather['main'] : null;
              final temp = main != null ? (main['temp'] ?? '--') : '--';
              final humidity = main != null ? (main['humidity'] ?? '--') : '--';

              final tempVal = Get.locale?.languageCode == 'bn'
                  ? _toBanglaNumber('$temp')
                  : '$temp';
              final humidityVal = Get.locale?.languageCode == 'bn'
                  ? _toBanglaNumber('$humidity')
                  : '$humidity';

              return CommonAppBar(
                title: 'automation_settings_menu'.tr,
                cityName: "dhaka".tr,
                leading: IconButton(
                  onPressed: () {
                    if (controller.hasUnsavedChanges) {
                      _showUnsavedDialog(context);
                    } else {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Get.back();
                      }
                    }
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                ),
                date: homeController.formattedDate.value,
                time: homeController.formattedTime.value,
                temp: '$tempVal${'°C'.tr}',
                humidity: '$humidityVal%',
              );
            }),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonContainer(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: CommonText(
                                    "enable_automation".tr,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                CommonSwitch(
                                  value: controller.isAutomationEnabled.value,
                                  onChanged: (value) {
                                    controller.isAutomationEnabled.value =
                                        value;
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildValueField(
                              label: "do_min_value".tr,
                              controller: controller.doMinController,
                              hint: "e.g. 3.5",
                            ),
                            const SizedBox(height: 16),
                            _buildValueField(
                              label: "do_max_value".tr,
                              controller: controller.doMaxController,
                              hint: "e.g. 7.0",
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "automation_note".tr,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: controller.isSaving.value
                                    ? null
                                    : () => controller.saveSettings(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff0370c3),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  elevation: 4,
                                  shadowColor: Colors.black.withValues(
                                    alpha: 0.3,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: controller.isSaving.value
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : CommonText(
                                        "save_settings".tr,
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: 16, fontWeight: FontWeight.w600),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  void _showUnsavedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("unsaved_changes".tr),
        content: Text("unsaved_changes_msg".tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("stay".tr),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.back();
            },
            child: Text("discard".tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
