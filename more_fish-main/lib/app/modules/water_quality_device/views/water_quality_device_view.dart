
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import 'package:more_fish/app/common_widgets/common_text.dart';
import 'package:more_fish/app/common_widgets/common_switch.dart';
import 'package:more_fish/app/service/service.dart';
import '../../../common_widgets/common_app_bar.dart';
import '../../../common_widgets/common_container.dart';
import '../../../routes/app_pages.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/water_quality_device_controller.dart';

class WaterQualityDeviceView extends GetView<WaterQualityDeviceController> {
  const WaterQualityDeviceView({super.key});

  String _formatSensorValue({
    required String? sensorName,
    required String? rawValue,
  }) {
    final parsedValue = double.tryParse(rawValue ?? '');
    if (parsedValue == null) return '0';

    final normalizedSensorName = sensorName?.trim().toUpperCase();
    // DO value restriction (clamped 1.62 - 16.0) removed as requested.
    final displayValue = parsedValue;

    return displayValue.toStringAsFixed(2);
  }

  Widget _getSensorIconWidget(String? sensorName, String? sensorIconFromApi) {
    final name = (sensorName ?? '').trim().toLowerCase();
    if (name == 'do') {
      return Image.asset(
        'assets/icons/water_quality_check.png',
        height: 40,
        width: 40,
        fit: BoxFit.contain,
      );
    } else if (name == 'ph') {
      return Image.asset(
        'assets/icons/ph.png',
        height: 40,
        width: 40,
        fit: BoxFit.contain,
      );
    } else if (name == 'temperature' || name.contains('temp')) {
      return Image.asset(
        'assets/icons/poultry_temperature.png',
        height: 40,
        width: 40,
        fit: BoxFit.contain,
      );
    } else if (name == 'nh3') {
      return Image.asset(
        'assets/icons/nh3.PNG',
        height: 70,
        width: 80,
        fit: BoxFit.cover,
      );
    } else if (name == 'tds') {
      return Image.asset(
        'assets/icons/tds.PNG',
        height: 60,
        width: 60,
        fit: BoxFit.contain,
      );
    } else if (name == 'salinity') {
      return Image.asset(
        'assets/icons/salinity.png',
        height: 70,
        width: 80,
        fit: BoxFit.cover,
      );
    } else {
      return Image.network(
        "${ApiService.baseUrl}/$sensorIconFromApi",
        height: 40,
        width: 40,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.sensors, size: 40, color: Colors.grey),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.put(HomeController());
    // Pull-to-refresh handler: attempt to refresh pond data but ensure
    // the refresh Future completes within 2 seconds for snappy UI.
    Future<void> handlePullToRefresh() async {
      try {
        final fetch = controller.pondData(id: controller.selectedAstId.value);
        await fetch.timeout(const Duration(seconds: 2), onTimeout: () {});
      } catch (_) {
        // ignore — keep refresh lightweight
      }
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xffd4fcfd),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            final box = context.findRenderObject() as RenderBox?;
            final localPosition = box?.globalToLocal(details.globalPosition);

            if (localPosition != null &&
                localPosition.dy > MediaQuery.of(context).size.height * 0.4) {
              return;
            }

            if (controller.commandInProgress.value) {
              controller.commandInProgress.value = false;
              debugPrint('[ui] User dismissed loading via tap');
              return;
            }

            controller.pondDataResponse.value = null;
            controller.pondList();
            controller.sensorList();
            controller.CompanyList();
          },
          child: Column(
            children: [
              Obx(() {
                final weather = homeController.weatherData;
                final main = (weather != null && weather.isNotEmpty)
                    ? weather['main']
                    : null;
                final temp = main != null ? (main['temp'] ?? '--') : '--';
                final humidity =
                    main != null ? (main['humidity'] ?? '--') : '--';

                return CommonAppBar(
                  title: 'title'.tr,
                  cityName: "dhaka".tr,
                  date: '${homeController.formattedDate}',
                  time: '${homeController.formattedTime}',
                  temp: '$temp°C',
                  humidity: '$humidity%',
                );
              }),
              Expanded(
                child: Obx(() {
                  var data = controller.pondDataResponse.value;
                  return data == null
                      ? const Center(child: Text('Waiting for live data...'))
                      : Column(
                          children: [
                            Center(
                              child: Obx(() {
                                final pondList =
                                    controller.pondListResponse.value?.data ??
                                    [];

                                if (pondList.isEmpty) {
                                  return const SizedBox();
                                }

                                final astNameIdList = pondList
                                    .map(
                                      (pond) => {
                                        'astName': pond.astName,
                                        'id': pond.id,
                                      },
                                    )
                                    .toList();

                                final astNames = astNameIdList
                                    .map((e) => e['astName'] as String)
                                    .toList();

                                if (!astNames.contains(
                                  controller.selectedAstName.value,
                                )) {
                                  controller.selectedAstName.value =
                                      astNames.first;
                                }

                                return Column(
                                  children: [
                                    const SizedBox(height: 12),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton2<String>(
                                          isExpanded: true,
                                          value:
                                              controller.selectedAstName.value,
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              final selectedItem = astNameIdList
                                                  .firstWhere(
                                                    (e) =>
                                                        e['astName'] ==
                                                        newValue,
                                                  );
                                              final selectedId =
                                                  selectedItem['id'];
                                              controller.selectAsset(
                                                name: newValue,
                                                id: selectedId as int,
                                              );
                                            }
                                          },
                                          items: astNames
                                              .map<DropdownMenuItem<String>>((
                                                String value,
                                              ) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: CommonText(
                                                    value,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                );
                                              })
                                              .toList(),
                                          buttonStyleData: ButtonStyleData(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                            height: 60,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          dropdownStyleData: DropdownStyleData(
                                            maxHeight: 300,
                                            direction:
                                                DropdownDirection.textDirection,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          iconStyleData: const IconStyleData(
                                            icon: Icon(
                                              Icons.arrow_drop_down,
                                              size: 35,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: handlePullToRefresh,
                                displacement: 40,
                                color: Theme.of(context).primaryColor,
                                child: SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 12),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    data
                                                                .data
                                                                .devices[0]
                                                                .deviceStatus ==
                                                            'Online'
                                                        ? Container(
                                                            height: 16,
                                                            width: 16,
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  const Color(
                                                                    0xff00cc00,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    100,
                                                                  ),
                                                            ),
                                                          )
                                                        : Container(
                                                            height: 18,
                                                            width: 18,
                                                            decoration:
                                                                BoxDecoration(
                                                                  color: Colors
                                                                      .red,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        100,
                                                                      ),
                                                                ),
                                                          ),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: CommonText(
                                                        data
                                                            .data
                                                            .devices[0]
                                                            .deviceName,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        color: const Color(
                                                          0xff0370c3,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                  ],
                                                ),
                                              ),
                                              CommonText(
                                                data
                                                    .data
                                                    .devices[0]
                                                    .sensors[0]
                                                    .dataTime,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                textAlign: TextAlign.center,
                                                color: const Color(0xff0370c3),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          height: 2,
                                          color: const Color(0xff0370c3),
                                        ),

                                        // Sensors Grid
                                        Obx(() {
                                          return GridView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 16,
                                            ),
                                            itemCount: controller
                                                .pondDataResponse
                                                .value
                                                ?.data
                                                .devices[0]
                                                .sensors
                                                .length,
                                            shrinkWrap: true,
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  crossAxisSpacing: 10,
                                                  mainAxisSpacing: 10,
                                                  childAspectRatio: 1.3,
                                                ),
                                            itemBuilder: (context, index) {
                                              final devices = controller
                                                  .pondDataResponse
                                                  .value
                                                  ?.data
                                                  .devices;
                                              
                                              if (devices == null || devices.isEmpty) {
                                                return const SizedBox.shrink();
                                              }

                                              var sensorData = devices[0].sensors[index];

                                              // Company ID logic (unchanged)
                                              final companyData = controller.companyListResponse.value?.data;
                                              final pondData = controller.pondListResponse.value?.data;

                                              if (companyData != null && pondData != null && pondData.isNotEmpty) {
                                                for (var i in companyData) {
                                                  if (i.name == pondData[0].astName) {
                                                    controller.comId.value = i.id!;
                                                    break;
                                                  }
                                                }
                                              }

                                              return InkWell(
                                                onTap: () {
                                                  final passedAssetId =
                                                      controller
                                                          .pondDataResponse
                                                          .value
                                                          ?.data
                                                          .assetId ??
                                                      controller
                                                          .selectedAstId
                                                          .value
                                                          .toString();

                                                  String? mappedSensorIdString;
                                                  try {
                                                    final sensorName =
                                                        (sensorData?.sensorName ??
                                                                '')
                                                            .toString()
                                                            .toLowerCase();
                                                    final mapped = controller
                                                        .sensorListResponse
                                                        .value
                                                        ?.data
                                                        .firstWhere(
                                                          (s) =>
                                                              s.sensorSensorName
                                                                  .toString()
                                                                  .toLowerCase() ==
                                                              sensorName,
                                                        );
                                                    if (mapped != null) {
                                                      mappedSensorIdString =
                                                          mapped.sensorId
                                                              .toString();
                                                    }
                                                  } catch (_) {
                                                    mappedSensorIdString = null;
                                                  }

                                                  final sensorIdForGraph =
                                                      mappedSensorIdString ??
                                                      sensorData?.sensorId;

                                                  Get.toNamed(
                                                    Routes.GRAPH,
                                                    arguments: {
                                                      "comId": controller
                                                          .comId
                                                          .value,
                                                      "assetId": passedAssetId,
                                                      "sensorId":
                                                          sensorIdForGraph,
                                                      "type": "daily",
                                                    },
                                                  );
                                                },
                                                child: CommonContainer(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 4,
                                                      ),
                                                  child: Column(
                                                    children: [
                                                      Expanded(
                                                        child:
                                                            _getSensorIconWidget(
                                                              sensorData
                                                                  ?.sensorName,
                                                              sensorData
                                                                  ?.sensorIcon,
                                                            ),
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                CommonText(
                                                                  sensorData?.dangerStatus ==
                                                                          "invalid"
                                                                      ? "No Data"
                                                                      : _formatSensorValue(
                                                                          sensorName:
                                                                              sensorData?.sensorName,
                                                                          rawValue:
                                                                              sensorData?.lastValue,
                                                                        ),
                                                                  fontSize:
                                                                      sensorData
                                                                              ?.dangerStatus ==
                                                                          "invalid"
                                                                      ? 16
                                                                      : 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      sensorData
                                                                              ?.dangerStatus ==
                                                                          "perfect"
                                                                      ? const Color(
                                                                          0xff00cc00,
                                                                        )
                                                                      : Colors
                                                                            .red,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                                const SizedBox(
                                                                  width: 3,
                                                                ),
                                                                CommonText(
                                                                  sensorData?.dangerStatus ==
                                                                          "invalid"
                                                                      ? ""
                                                                      : "${sensorData?.sensorUnit}",
                                                                  fontSize: 20,
                                                                  color:
                                                                      sensorData
                                                                              ?.dangerStatus ==
                                                                          "perfect"
                                                                      ? const Color(
                                                                          0xff00cc00,
                                                                        )
                                                                      : Colors
                                                                            .red,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ],
                                                            ),
                                                            CommonText(
                                                              "${sensorData?.sensorName}",
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }),

                                        const SizedBox(height: 16),

                                        // ==================== AERATORS SECTION (UPDATED) ====================
                                        Obx(() {
                                          final aerators =
                                              controller
                                                  .pondDataResponse
                                                  .value
                                                  ?.data
                                                  .devices[0]
                                                  .aerators ??
                                              [];
                                          return ListView.builder(
                                            itemCount: aerators.length,
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemBuilder: (BuildContext context, int index) {
                                              final aerator = aerators[index];

                                              final bool isOnline =
                                                  aerator.isOnline == true;

                                              return Obx(() {
                                                final bool switchValue =
                                                    controller.aeratorSwitchValueFor(
                                                  aerator.aeratorPk,
                                                  fallback: aerator.isRunning == true,
                                                );

                                                return CommonContainer(
                                                  margin: const EdgeInsets.only(
                                                    left: 14,
                                                    right: 14,
                                                    bottom: 16,
                                                  ),
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 20,
                                                  ),
                                                  border: Border.all(
                                                    color: switchValue
                                                        ? Colors.green.withOpacity(0.5)
                                                        : Colors.black12,
                                                    width: switchValue ? 1.5 : 1,
                                                  ),
                                                  boxShadow: [
                                                    if (switchValue && isOnline)
                                                      BoxShadow(
                                                        color: Colors.green.withOpacity(0.2),
                                                        blurRadius: 10,
                                                        spreadRadius: 2,
                                                      ),
                                                  ],
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: 18,
                                                            height: 18,
                                                            decoration: BoxDecoration(
                                                              color: isOnline
                                                                  ? const Color(
                                                                      0xff2fbf71,
                                                                    )
                                                                  : const Color(
                                                                      0xffe74c3c,
                                                                    ),
                                                              shape: BoxShape.circle,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 12,
                                                          ),
                                                            SizedBox(
                                                              width: MediaQuery.of(
                                                                    context,
                                                                  ).size.width -
                                                                  220,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  CommonText(
                                                                    aerator
                                                                        .aeratorName,
                                                                    fontSize: 20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 1,
                                                                  ),
                                                                  if (controller
                                                                      .isAutomationEnabled
                                                                      .value)
                                                                    const CommonText(
                                                                      'Auto Mode',
                                                                      fontSize: 12,
                                                                      color: Colors
                                                                          .blue,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        // CommonSwitch(
                                                        //   value: switchValue,
                                                        //   onChanged: (bool value) {
                                                        //     if (controller.isAutomationEnabled.value) {
                                                        //       controller.showAutomationWarning();
                                                        //       return;
                                                        //     }
                                                        //     if (!isOnline || controller.isAeratorBusy(aerator.aeratorPk)) {
                                                        //       return;
                                                        //     }
                                                        //     controller.aeratorCommand(
                                                        //       id: aerator.aeratorId,
                                                        //       command: value ? 1 : 0,
                                                        //       index: index,
                                                        //       isOnline: isOnline,
                                                        //       aeratorPk: aerator.aeratorPk,
                                                        //     );
                                                        //   },
                                                        //   activeColor: Colors.green,
                                                        //   inactiveColor: Colors.red,
                                                        // ),
                                                      CommonSwitch(
                                                        value: switchValue,
                                                        onChanged: (bool value) {
                                                          // Block manual control when automation is enabled
                                                          if (controller.isAutomationEnabled.value) {
                                                            ScaffoldMessenger.of(context).hideCurrentSnackBar();

                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                  'Manual control is disabled while Automation is ON.',
                                                                ),
                                                                duration: Duration(seconds: 2),
                                                              ),
                                                            );

                                                            return;
                                                          }

                                                          if (!isOnline || controller.isAeratorBusy(aerator.aeratorPk)) {
                                                            return;
                                                          }

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
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              });
                                            },
                                          );
                                        }),

                                        // ==================== CLEANER SECTION ====================
                                        Obx(() {
                                          final cleaner =
                                              controller.cleanerStatusResponse.value;
                                          if (cleaner == null ||
                                              cleaner.success == false) {
                                            return const SizedBox.shrink();
                                          }

                                          final bool isOn = cleaner.isOn == true;

                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CommonContainer(
                                                margin: const EdgeInsets.only(
                                                  left: 14,
                                                  right: 14,
                                                  bottom: 8,
                                                ),
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 18,
                                                ),
                                                border: Border.all(
                                                  color: isOn
                                                      ? Colors.green.withOpacity(0.5)
                                                      : Colors.black12,
                                                  width: isOn ? 1.5 : 1,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 18,
                                                      height: 18,
                                                      decoration: BoxDecoration(
                                                        color: isOn
                                                            ? const Color(0xff2fbf71)
                                                            : Colors.grey,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    const Expanded(
                                                      child: CommonText(
                                                        'Auto-Cleaner',
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    CommonText(
                                                      isOn ? 'On' : 'Off',
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: isOn
                                                          ? Colors.green
                                                          : Colors.grey,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 18),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    if (cleaner.lastRunAt != null)
                                                      CommonText(
                                                        'Last Run: ${cleaner.lastRunAt}',
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                    const SizedBox(height: 6),
                                                    CommonText(
                                                      'Every day at 2:00 PM Bangladesh time, the cleaner turns ON.',
                                                      fontSize: 13,
                                                      color: Colors.grey.shade700,
                                                      maxLines: 2,
                                                      overflow: TextOverflow.visible,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                            ],
                                          );
                                        }),

                                        // Warning Messages (unchanged)
                                        controller.pondDataResponse.value ==
                                                null
                                            ? const SizedBox()
                                            : Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 12,
                                                    ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: List.generate(
                                                    controller
                                                        .pondDataResponse
                                                        .value!
                                                        .data
                                                        .devices[0]
                                                        .sensors
                                                        .length,
                                                    (index) {
                                                      var sensor = controller
                                                          .pondDataResponse
                                                          .value!
                                                          .data
                                                          .devices[0]
                                                          .sensors[index];
                                                      var data =
                                                          sensor.sensorName;
                                                      var value =
                                                          double.tryParse(
                                                            sensor.lastValue
                                                                .toString(),
                                                          ) ??
                                                          0.0;

                                                      if (data == "pH" &&
                                                          value < 7) {
                                                        return const Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            CommonText(
                                                              "⚠️ Warning: ",
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                            Expanded(
                                                              child: CommonText(
                                                                "চুন প্রয়োগ করুন।",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                maxLines: 3,
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                      if (data == "pH" &&
                                                          value > 8.5) {
                                                        return const Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            CommonText(
                                                              "⚠️ Warning: ",
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                            Expanded(
                                                              child: CommonText(
                                                                "টিএসপি, জিপসাম, ভিনেগার অথবা গভীর নলকূপের পানি যোগ করুন।",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                maxLines: 3,
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                      if (data == "DO" &&
                                                          value < 3) {
                                                        return const Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            CommonText(
                                                              "⚠️ Warning: ",
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                            Expanded(
                                                              child: CommonText(
                                                                "এরেটর চালান বা গভীর নলকূপের পানি যোগ করুন।",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                maxLines: 3,
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                      if (data == "TDS" &&
                                                          value < 100) {
                                                        return const Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            CommonText(
                                                              "⚠️ Warning: ",
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                            Expanded(
                                                              child: CommonText(
                                                                "চুন, জিপসাম অথবা লবণ যোগ করুন।",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                maxLines: 3,
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                      if (data == "TDS" &&
                                                          value > 1000) {
                                                        return const Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            CommonText(
                                                              "⚠️ Warning: ",
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                            Expanded(
                                                              child: CommonText(
                                                                "গভীর নলকূপের পানি যোগ করুন।",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                maxLines: 3,
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                      if (data ==
                                                              "Temperature" &&
                                                          value > 34) {
                                                        return const Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            CommonText(
                                                              "⚠️ Warning: ",
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                            Expanded(
                                                              child: CommonText(
                                                                "গভীর নলকূপের পানি যোগ করুন।",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                maxLines: 3,
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                      if (data == "NH3" &&
                                                          value > 0.5) {
                                                        return const Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            CommonText(
                                                              "⚠️ Warning: ",
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                            Expanded(
                                                              child: CommonText(
                                                                "হররা বা জাল টানুন।",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                maxLines: 3,
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      } else {
                                                        return const CommonText(
                                                          "",
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
