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
              return CommonAppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: 'nano_bubble_aeration_system'.tr,
                cityName: "dhaka".tr,
                date: '${homeController.formattedDate}',
                time: '${homeController.formattedTime}',
                temp: '${homeController.weatherData['main']?['temp'] ?? ''}°C',
                humidity:
                    '${homeController.weatherData['main']?['humidity'] ?? ''}%',
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CommonText(
                                      double.tryParse(
                                            doSensor.lastValue,
                                          )?.toStringAsFixed(2) ??
                                          '0.00',
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: doSensor.dangerStatus == "perfect"
                                          ? const Color(0xff00cc00)
                                          : Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    CommonText(
                                      doSensor.sensorUnit,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                      color: doSensor.dangerStatus == "perfect"
                                          ? const Color(0xff00cc00)
                                          : Colors.red,
                                    ),
                                  ],
                                ),
                                CommonText(
                                  doSensor.sensorName,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (aerators.isNotEmpty) ...[
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 8, bottom: 12),
                              child: CommonText(
                                "Aerators Control",
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
                                          aerator.aeratorName,
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
