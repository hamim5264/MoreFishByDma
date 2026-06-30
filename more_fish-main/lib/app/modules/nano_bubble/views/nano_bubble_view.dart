import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../../common_widgets/common_app_bar.dart';
import '../../../common_widgets/common_switch.dart';
import '../../../common_widgets/common_container.dart';
import '../../../common_widgets/common_text.dart';
import '../../home/controllers/home_controller.dart';
import '../../water_quality_device/controllers/water_quality_device_controller.dart';

class NanoBubbleView extends GetView<WaterQualityDeviceController> {
  const NanoBubbleView({super.key});

  String _formatSensorValue({
    required String? sensorName,
    required String? rawValue,
  }) {
    final parsedValue = double.tryParse(rawValue ?? '');
    if (parsedValue == null) return Get.locale?.languageCode == 'bn' ? '০' : '0';

    final displayValue = parsedValue;
    String valueString = displayValue.toStringAsFixed(2);

    if (Get.locale?.languageCode == 'bn') {
      return _toBanglaNumber(valueString);
    }

    return valueString;
  }

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
    HomeController homeController = Get.put(HomeController());

    Future<void> handlePullToRefresh() async {
      try {
        final fetch = controller.pondData(id: controller.selectedAstId.value);
        await fetch.timeout(const Duration(seconds: 2), onTimeout: () {});
      } catch (_) {}
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xffd4fcfd),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: Column(
          children: [
            const SizedBox(height: 40),
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
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: 'nano_bubble_aeration_system'.tr,
                cityName: "dhaka".tr,
                date: homeController.formattedDate.value,
                time: homeController.formattedTime.value,
                temp: '$tempVal${'°C'.tr}',
                humidity: '$humidityVal%',
              );
            }),
            Expanded(
              child: Obx(() {
                var data = controller.pondDataResponse.value;
                if (data == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                final devices = data.data.devices;
                if (devices.isEmpty) {
                  return const Center(child: Text('No devices found'));
                }

                final device = devices[0];
                final doSensor = device.sensors.firstWhereOrNull(
                  (s) => s.sensorName.trim().toUpperCase() == 'DO',
                );
                final aerators = device.aerators;

                return RefreshIndicator(
                  onRefresh: handlePullToRefresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        if (doSensor != null) ...[
                          CommonContainer(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/icons/water_quality_check.png',
                                  height: 80,
                                  width: 80,
                                ),
                                const SizedBox(height: 16),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CommonText(
                                        _formatSensorValue(
                                          sensorName: doSensor.sensorName,
                                          rawValue: doSensor.lastValue,
                                        ),
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            doSensor.dangerStatus == "perfect"
                                                ? const Color(0xff00cc00)
                                                : Colors.red,
                                      ),
                                      const SizedBox(width: 8),
                                      CommonText(
                                        doSensor.sensorUnit.trim().tr,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            doSensor.dangerStatus == "perfect"
                                                ? const Color(0xff00cc00)
                                                : Colors.red,
                                      ),
                                    ],
                                  ),
                                ),
                                CommonText(
                                  doSensor.sensorName.trim().tr,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (aerators.isNotEmpty) ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, bottom: 12),
                              child: CommonText(
                                "switch_controls".tr,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ListView.builder(
                            itemCount: aerators.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final aerator = aerators[index];
                              final isOnline = aerator.isOnline == true;

                              return CommonContainer(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: isOnline
                                                ? const Color(0xff2fbf71)
                                                : const Color(0xffe74c3c),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        CommonText(
                                          Get.locale?.languageCode == 'bn'
                                              ? _toBanglaNumber(
                                                aerator.aeratorName
                                                    .replaceAll(
                                                      'Aerator',
                                                      'এয়ারেটর',
                                                    )
                                                    .replaceAll(
                                                      'Aerator'.toLowerCase(),
                                                      'এয়ারেটর',
                                                    ),
                                              )
                                              : aerator.aeratorName,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ],
                                    ),
                                    Obx(() {
                                      final bool switchValue = controller
                                          .aeratorSwitchValueFor(
                                            aerator.aeratorPk,
                                            fallback: aerator.isRunning == true,
                                          );

                                      return CommonSwitch(
                                        value: switchValue,
                                        onChanged:
                                            !isOnline ||
                                                controller.isAeratorBusy(
                                                  aerator.aeratorPk,
                                                )
                                            ? null
                                            : (bool value) {
                                                controller.aeratorCommand(
                                                  id: aerator.aeratorId,
                                                  command: value ? 1 : 0,
                                                  index: index,
                                                  isOnline: isOnline,
                                                  aeratorPk: aerator.aeratorPk,
                                                );
                                              },
                                        activeColor: Colors.green,
                                        inactiveColor: Colors.red,
                                      );
                                    }),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                        if (doSensor == null && aerators.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                "No live DO data or Aerators found for this pond.",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
