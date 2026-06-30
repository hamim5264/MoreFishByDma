import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../common_widgets/common_app_bar.dart';
import '../../../common_widgets/common_switch.dart';
import '../../../repo/poultry_live_models.dart';
import '../controllers/poultry_live_monitoring_controller.dart';
import '../controllers/poultry_header_controller.dart';

class PoultryLiveMonitoringView extends StatelessWidget {
  const PoultryLiveMonitoringView({super.key});

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
                child: Builder(
                  builder: (_) {
                    final ctrl = Get.find<PoultryLiveMonitoringController>();

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ctrl.refreshWhenPageVisible();
                    });

                    return _LoggedInDashboard(
                      controller: ctrl,
                      toBangla: _toBanglaNumber,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoggedInDashboard extends StatelessWidget {
  const _LoggedInDashboard({required this.controller, required this.toBangla});

  final PoultryLiveMonitoringController controller;
  final String Function(String) toBangla;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.liveData.value == null) {
        return Center(child: Text('waiting_for_live_data'.tr));
      }

      if (controller.error.value.isNotEmpty &&
          controller.liveData.value == null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${'failed_to_load'.tr}: ${controller.error.value}'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: controller.loadDevices,
                child: Text('try_again'.tr),
              ),
            ],
          ),
        );
      }

      final live = controller.liveData.value;
      final dynamicMetrics = live?.metrics ?? const <PoultrySensorMetric>[];

      return RefreshIndicator(
        onRefresh: () async {
          final refresh = controller.refreshLiveData();
          await Future.any([
            refresh,
            Future.delayed(const Duration(seconds: 2)),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                _DeviceDropdown(controller: controller),
                const SizedBox(height: 10),
                if (live != null)
                  _DeviceHeader(
                    deviceName: live.deviceId,
                    deviceStatus: live.deviceStatus,
                    timestampIso: live.timestamp,
                    toBangla: toBangla,
                  ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: dynamicMetrics
                      .map(
                        (metric) => _MetricCard(
                          onTap: () => controller.openSensorGraph(metric),
                          iconAsset: _metricIconAsset(metric.name),
                          iconData: _dynamicMetricIcon(metric.name),
                          title: metric.title.tr,
                          value: _formatDynamicMetricValue(metric, toBangla),
                          statusColor: _metricTextColor(metric.dangerStatus),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),
                _SwitchesSection(
                  controller: controller,
                  live: live,
                  toBangla: toBangla,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffdbcc68),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Note: The parameters are changeable according to installation of device.'.tr,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                if (controller.error.value.isNotEmpty)
                  Text(
                    'Last error: ${controller.error.value}',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _DeviceDropdown extends StatelessWidget {
  const _DeviceDropdown({required this.controller});

  final PoultryLiveMonitoringController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.devices;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 234, 240, 183),
          borderRadius: BorderRadius.circular(14),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: controller.selectedDeviceId.value.isEmpty
                ? null
                : controller.selectedDeviceId.value,
            hint: Text('select_device'.tr),
            icon: const Icon(Icons.keyboard_arrow_down),
            items: items
                .map(
                  (d) => DropdownMenuItem<String>(
                    value: d.id,
                    child: Text(
                      d.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) controller.onDeviceChanged(v);
            },
          ),
        ),
      );
    });
  }
}

class _DeviceHeader extends StatelessWidget {
  const _DeviceHeader({
    required this.deviceName,
    required this.deviceStatus,
    required this.timestampIso,
    required this.toBangla,
  });

  final String deviceName;
  final String deviceStatus;
  final String timestampIso;
  final String Function(String) toBangla;

  @override
  Widget build(BuildContext context) {
    String ts = timestampIso;

    try {
      final parsed = DateFormat('dd MMM yyyy hh:mm a').parse(timestampIso);

      final dt = parsed.add(const Duration(hours: 6));

      final datePart =
          '${dt.day.toString().padLeft(2, '0')} ${_monthName(dt.month)} ${dt.year}';
      final timePart = DateFormat('h:mm a').format(dt);

      if (Get.locale?.languageCode == 'bn') {
        ts = '${toBangla(datePart)}   ${toBangla(timePart)}';
      } else {
        ts = '$datePart   $timePart';
      }
    } catch (e) {
      debugPrint('Time parse error: $e');
    }

    return Row(
      children: [
        Icon(Icons.circle, color: _deviceSignalColor(deviceStatus), size: 12),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            deviceName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ),
        Text(ts, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  static String _monthName(int m) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return (m >= 1 && m <= 12) ? names[m - 1] : '';
  }

  static Color _deviceSignalColor(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized == 'offline') {
      return Colors.red;
    }
    return Colors.green;
  }
}

class _SwitchesSection extends StatelessWidget {
  const _SwitchesSection({
    required this.controller,
    required this.live,
    required this.toBangla,
  });

  final PoultryLiveMonitoringController controller;
  final PoultryLiveData? live;
  final String Function(String) toBangla;

  @override
  Widget build(BuildContext context) {
    final switches = live?.switches ?? const <PoultrySwitch>[];
    if (switches.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool isOnline = live?.isOnline ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xfff3f4c5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  color: isOnline ? Colors.green : Colors.red,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Text(
                  'Switch Controls'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 6.0;
              final itemWidth = (constraints.maxWidth - spacing) / 2;

              return Wrap(
                spacing: spacing,
                runSpacing: 6,
                children: switches
                    .map(
                      (item) => SizedBox(
                        width: itemWidth,
                        child: _SwitchCard(
                          controller: controller,
                          item: item,
                          isDeviceOnline: isOnline,
                          toBangla: toBangla,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SwitchCard extends StatelessWidget {
  const _SwitchCard({
    required this.controller,
    required this.item,
    required this.isDeviceOnline,
    required this.toBangla,
  });

  final PoultryLiveMonitoringController controller;
  final PoultrySwitch item;
  final bool isDeviceOnline;
  final String Function(String) toBangla;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final busy = controller.switchBusy[item.switchId] ?? false;
      final value = controller.switchUiState[item.switchId] ?? item.isOn;
      final bool automationActive =
          controller.liveData.value?.automationEnabled ?? false;

      final bool canInteract =
          isDeviceOnline && item.isActive && !busy && !automationActive;

      String name = item.switchName.isEmpty ? item.switchId : item.switchName;
      if (Get.locale?.languageCode == 'bn') {
        name = toBangla(
          name
              .replaceAll('Aerator', 'এয়ারেটর')
              .replaceAll('Feeder', 'ফিডার')
              .replaceAll('Fan', 'ফ্যান'),
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: (isDeviceOnline && !automationActive)
              ? const Color.fromARGB(255, 216, 226, 180)
              : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? Colors.green.withValues(alpha: 0.5) : Colors.black12,
            width: value ? 1.5 : 1,
          ),
          boxShadow: [
            if (value && isDeviceOnline && !automationActive)
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: (isDeviceOnline && !automationActive)
                          ? Colors.black
                          : Colors.grey.shade600,
                    ),
                  ),
                  if (automationActive)
                    Text(
                      'auto_mode'.tr,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            CommonSwitch(
              value: value,
              activeColor: Colors.green,
              inactiveColor: Colors.red,
              onChanged: !canInteract
                  ? (v) {
                      if (automationActive) {
                        _showAutomationSnackbar();
                      }
                    }
                  : (v) {
                      controller.onSwitchChanged(item: item, nextValue: v);
                    },
            ),
          ],
        ),
      );
    });
  }

  void _showAutomationSnackbar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        'Automation Active',
        'Manual control is disabled while automation is ON. Turn off automation in Settings to control manually.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
        duration: const Duration(seconds: 4),
      );
    });
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    this.onTap,
    this.iconAsset,
    this.iconData,
    required this.title,
    required this.value,
    required this.statusColor,
  });

  final VoidCallback? onTap;
  final String? iconAsset;
  final IconData? iconData;
  final String title;
  final String value;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final w = (MediaQuery.of(context).size.width - 14 * 2 - 12) / 2;
    return SizedBox(
      width: w,
      height: 140,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xfff3f4c5),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.black12, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (iconAsset != null)
                  Image.asset(iconAsset!, height: 42, fit: BoxFit.contain)
                else
                  Icon(
                    iconData ?? Icons.sensors,
                    size: 36,
                    color: Colors.black87,
                  ),
                const SizedBox(height: 6),
                FittedBox(
                  child: Text(
                    value,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatDynamicMetricValue(
  PoultrySensorMetric metric,
  String Function(String) toBangla,
) {
  final unit = metric.unit.trim();
  final value = metric.value;
  String formatted = value % 1 == 0
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);

  if (Get.locale?.languageCode == 'bn') {
    formatted = toBangla(formatted);
    if (unit.isEmpty || unit.toLowerCase() == 'null') {
      return formatted;
    }
    return '$formatted ${unit.tr}';
  }

  if (unit.isEmpty || unit.toLowerCase() == 'null') {
    return formatted;
  }
  return '$formatted $unit';
}

Color _metricTextColor(String status) {
  final normalized = status.trim().toLowerCase();
  if (normalized == 'perfect') {
    return Colors.green;
  }
  return Colors.red;
}

IconData _dynamicMetricIcon(String name) {
  switch (name) {
    case 'light_intensity':
      return Icons.light_mode;
    case 'pm1':
    case 'pm25':
    case 'pm4':
    case 'pm10':
      return Icons.blur_on;
    default:
      return Icons.sensors;
  }
}

String? _metricIconAsset(String name) {
  switch (name) {
    case 'pm1':
    case 'pm1_0':
    case 'pm25':
    case 'pm2_5':
    case 'pm4':
    case 'pm4_0':
    case 'pm10':
      return 'assets/icons/poultry_ch4.png';
    case 'aqi':
      return 'assets/icons/poultry_co.png';
    case 'nh3_gas':
      return 'assets/icons/poultry_nh3.png';
    case 'temperature':
      return 'assets/icons/poultry_temperature.png';
    case 'humidity':
      return 'assets/icons/poultry_humidity.png';
    case 'co2':
      return 'assets/icons/poultry_co2.png';
    case 'tvoc':
      return 'assets/icons/cattle_voc.png';
    case 'sound_db':
      return 'assets/icons/poultry_noise.png';
    case 'methane_ppm':
      return 'assets/icons/poultry_ch4.png';
    case 'light_intensity':
      return 'assets/icons/poultry_light_intensity.png';
    default:
      return null;
  }
}
