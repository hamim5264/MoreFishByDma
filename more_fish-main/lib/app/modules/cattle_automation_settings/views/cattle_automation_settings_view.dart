import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../common_widgets/common_app_bar.dart';
import '../../../common_widgets/common_container.dart';
import '../../../common_widgets/common_text.dart';
import '../../../common_widgets/common_switch.dart';
import '../controllers/cattle_automation_settings_controller.dart';
import '../../cattle_index/controllers/cattle_header_controller.dart';

class CattleAutomationSettingsView
    extends GetView<CattleAutomationSettingsController> {
  const CattleAutomationSettingsView({super.key});

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
    final header = Get.find<CattleHeaderController>();

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
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xffebffff),
          body: Column(
            children: [
              Obx(() => CommonAppBar(
                    title: 'automation_settings_menu'.tr,
                    cityName: header.district.value.tr,
                    leading: IconButton(
                      onPressed: () {
                        if (controller.hasUnsavedChanges) {
                          _showUnsavedDialog(context);
                        } else {
                          Get.back();
                        }
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                    date: header.formattedDate.value,
                    time: header.formattedTime.value,
                    temp: header.tempText.value,
                    humidity: header.humidityText.value,
                    logoAssetPath: 'assets/icons/dma_cattle_care.png',
                    backgroundColor: Colors.white,
                  )),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.farmId != null &&
                      controller.isSaving.value == false) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildMainToggle(),
                        const SizedBox(height: 16),
                        _buildFanSection(),
                        const SizedBox(height: 16),
                        _buildFoggerSection(),
                        const SizedBox(height: 16),
                        _buildLightSection(context),
                        const SizedBox(height: 30),
                        _buildSaveButton(),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainToggle() {
    return CommonContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CommonText(
            "enable_automation".tr,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          CommonSwitch(
            value: controller.isAutomationEnabled.value,
            onChanged: (value) {
              controller.isAutomationEnabled.value = value;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFanSection() {
    return CommonContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cyclone, color: Colors.blue),
              const SizedBox(width: 8),
              CommonText("Fan Control (Temp based)".tr,
                  fontSize: 16, fontWeight: FontWeight.bold),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildValueField(
                  label: "Min Temp (°C)".tr,
                  controller: controller.fanTempMinController,
                  hint: "20.0",
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildValueField(
                  label: "Max Temp (°C)".tr,
                  controller: controller.fanTempMaxController,
                  hint: "35.0",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFoggerSection() {
    return CommonContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop, color: Colors.cyan),
              const SizedBox(width: 8),
              CommonText("Fogger Control (Humidity based)".tr,
                  fontSize: 16, fontWeight: FontWeight.bold),
            ],
          ),
          const SizedBox(height: 16),
          _buildValueField(
            label: "Min Humidity (%)".tr,
            controller: controller.foggerHumidityMinController,
            hint: "40.0",
          ),
        ],
      ),
    );
  }

  Widget _buildLightSection(BuildContext context) {
    return CommonContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.orangeAccent),
                  const SizedBox(width: 8),
                  CommonText("Light Schedules".tr,
                      fontSize: 16, fontWeight: FontWeight.bold),
                ],
              ),
              IconButton(
                onPressed: () => _showAddTimeDialog(context),
                icon: const Icon(Icons.add_circle, color: Colors.green),
              )
            ],
          ),
          const SizedBox(height: 8),
          if (controller.lightSchedules.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CommonText("No schedules added".tr, color: Colors.grey),
              ),
            ),
          ...controller.lightSchedules.map((s) {
            String timeRange = "${s.startTime} - ${s.endTime}";
            if (Get.locale?.languageCode == 'bn') {
              timeRange = _toBanglaNumber(timeRange);
            }
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: CommonText(timeRange, fontWeight: FontWeight.w600),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => controller.deleteLightSchedule(s.id!),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            controller.isSaving.value ? null : () => controller.saveSettings(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: controller.isSaving.value
            ? const CircularProgressIndicator()
            : CommonText("Save Automation Settings".tr,
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
        CommonText(label, fontSize: 14, fontWeight: FontWeight.w600),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black12),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  void _showAddTimeDialog(BuildContext context) async {
    TimeOfDay? start = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 20, minute: 0),
        helpText: "SELECT START TIME".tr);
    if (start == null) return;

    if (!context.mounted) return;

    TimeOfDay? end = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 8, minute: 0),
        helpText: "SELECT END TIME".tr);
    if (end == null) return;

    final startStr =
        "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}:00";
    final endStr =
        "${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}:00";

    controller.addLightSchedule(startStr, endStr);
  }

  void _showUnsavedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Unsaved Changes".tr),
        content: Text("You have unsaved settings. Save or discard?".tr),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: Text("Discard".tr)),
          ElevatedButton(
              onPressed: () {
                Get.back();
                controller.saveSettings();
              },
              child: Text("Save".tr)),
        ],
      ),
    );
  }
}
