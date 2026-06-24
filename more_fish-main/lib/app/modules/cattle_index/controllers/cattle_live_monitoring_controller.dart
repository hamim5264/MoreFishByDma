import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../repo/cattle_live_repo.dart';
import '../../../response/cattle_farm_list_response.dart';
import '../../../response/cattle_farrm_dashboard_response.dart';
import 'cattle_header_controller.dart';

class CattleLiveMonitoringController extends GetxController {
  final CattleLiveDataRepository cattleLiveDataRepository =
      CattleLiveDataRepository();

  final cattleFarmListResponse = Rxn<CattleFarmListResponse>();
  final cattleFarmDashboardResponse = Rxn<CattleFarmDashboardResponse>();

  final selectedDeviceId = ''.obs;
  final isLoading = false.obs;
  final error = ''.obs;

  final switchUiState = <String, bool>{}.obs;
  final switchBusy = <String, bool>{}.obs;

  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    debugPrint('CattleMonitoringController: onInit');

    Future.delayed(const Duration(milliseconds: 200), () {
      if (cattleFarmListResponse.value == null) {
        fetchFarmList();
      } else {
        refreshLiveData(showLoader: false);
      }
    });

    _startBackgroundRefresh();
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  void _startBackgroundRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      final route = Get.currentRoute.toLowerCase();
      if (selectedDeviceId.value.isNotEmpty && route.contains('cattle')) {
        refreshLiveData(showLoader: false);
      }
    });
  }

  void _syncSwitchUiState() {
    final switches = cattleFarmDashboardResponse.value?.data?.device?.switches;

    if (switches == null) return;

    for (final item in switches) {
      if (item.switchId != null) {
        switchUiState[item.switchId!] = item.isOn ?? false;
      }
    }
  }

  Future<void> fetchFarmList() async {
    debugPrint('CattleMonitoring: fetchFarmList() start');

    if (cattleFarmListResponse.value == null) {
      isLoading.value = true;
    }
    error.value = '';

    try {
      final response = await cattleLiveDataRepository.getFarmList();
      await response.fold(
        (l) async {
          debugPrint('CattleMonitoring: fetchFarmList() error: ${l.message}');
          error.value = l.message;
          isLoading.value = false;
        },
        (r) async {
          debugPrint(
            'CattleMonitoring: fetchFarmList() success, found ${r.data?.length ?? 0} farms',
          );
          cattleFarmListResponse.value = r;
          if (r.data != null && r.data!.isNotEmpty) {
            final firstFarmId = r.data![0].id.toString();
            selectedDeviceId.value = firstFarmId;
            await fetchFarmDashboard(id: firstFarmId, showLoader: true);
          } else {
            debugPrint('CattleMonitoring: No farms in list');
            error.value = "No farms found for this account.";
            isLoading.value = false;
          }
        },
      );
    } catch (e) {
      debugPrint('CattleMonitoring: Exception in fetchFarmList: $e');
      error.value = "Unexpected error: $e";
      isLoading.value = false;
    }
  }

  Future<void> fetchFarmDashboard({
    required String id,
    bool showLoader = true,
  }) async {
    debugPrint('CattleMonitoring: fetchFarmDashboard(id: $id) start');

    if (showLoader &&
        (cattleFarmDashboardResponse.value == null ||
            selectedDeviceId.value != id)) {
      isLoading.value = true;
    }
    error.value = '';

    try {
      final response = await cattleLiveDataRepository.getFarmDashboard(id: id);
      response.fold(
        (l) {
          debugPrint(
            'CattleMonitoring: fetchFarmDashboard() error: ${l.message}',
          );
          error.value = l.message;
        },
        (r) {
          debugPrint('CattleMonitoring: fetchFarmDashboard() success');
          cattleFarmDashboardResponse.value = r;
          _syncSwitchUiState();
          if (Get.isRegistered<CattleHeaderController>()) {
            Get.find<CattleHeaderController>().updateFromDashboard(
              r.data?.weather,
            );
          }
        },
      );
    } catch (e) {
      debugPrint('CattleMonitoring: Exception in fetchFarmDashboard: $e');
      error.value = "Failed to load dashboard: $e";
    } finally {
      isLoading.value = false;
      debugPrint('CattleMonitoring: fetchFarmDashboard() finished');
    }
  }

  Future<void> onDeviceChanged(String id) async {
    selectedDeviceId.value = id;
    cattleFarmDashboardResponse.value = null;
    await fetchFarmDashboard(id: id);
  }

  Future<void> refreshLiveData({bool showLoader = true}) async {
    if (selectedDeviceId.value.isNotEmpty) {
      await fetchFarmDashboard(
        id: selectedDeviceId.value,
        showLoader: showLoader,
      );
    } else {
      await fetchFarmList();
    }
  }

  Future<void> toggleSwitch(String switchId, bool turnOn) async {
    if (switchId.trim().isEmpty) return;

    if (switchBusy[switchId] == true) return;

    switchBusy[switchId] = true;

    switchUiState[switchId] = turnOn;
    switchUiState.refresh();

    final result = await cattleLiveDataRepository.setSwitchState(
      switchId: switchId,
      turnOn: turnOn,
    );

    result.fold(
      (l) {
        debugPrint('Cattle Switch Error: ${l.message}');

        switchUiState[switchId] = !turnOn;
        switchUiState.refresh();

        Get.snackbar(
          'Command Failed',
          l.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      },
      (r) {
        Future.delayed(
          const Duration(seconds: 2),
          () => refreshLiveData(showLoader: false),
        );
      },
    );

    switchBusy[switchId] = false;
  }

  Sensor? getSensor(String name) {
    final sensors = cattleFarmDashboardResponse.value?.data?.device?.sensors;
    if (sensors == null) return null;
    try {
      return sensors.firstWhere(
        (s) => s.name?.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  void openSensorGraph(Sensor sensor) {
    final farmId = int.tryParse(selectedDeviceId.value.trim());

    if (farmId == null) {
      Get.snackbar(
        'Error',
        'Invalid farm selected',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    String displayName = sensor.name ?? 'Sensor';
    final n = displayName.toLowerCase();
    if (n == 'temperature') {
      displayName = 'Temperature';
    } else if (n == 'humidity') {
      displayName = 'Humidity';
    } else if (n == 'nh3_gas') {
      displayName = 'Ammonia (NH3)';
    } else if (n == 'tvoc') {
      displayName = 'TVOC';
    } else if (n == 'co2') {
      displayName = 'Carbon dioxide';
    } else if (n == 'pm2_5') {
      displayName = 'PM 2.5';
    } else if (n == 'pm1_0') {
      displayName = 'PM 1.0';
    } else if (n == 'methane_ppm') {
      displayName = 'Methane (CH4)';
    }

    Get.toNamed(
      Routes.GRAPH,
      arguments: {
        'flow': 'cattle',
        'farmId': farmId,
        'sensorKey': sensor.name,
        'sensorName': displayName,
        'unit': sensor.unit,
        'type': 'daily',
      },
    );
  }
}
