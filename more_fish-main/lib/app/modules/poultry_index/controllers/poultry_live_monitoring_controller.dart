import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../repo/poultry_api_live_repo.dart';
import '../../../repo/poultry_live_models.dart';
import '../../../repo/poultry_live_repo.dart';
import '../../../routes/app_pages.dart';
import '../../../service/local_storage.dart';
import 'package:more_fish/app/modules/cattle_index/controllers/cattle_header_controller.dart';

class PoultryLiveMonitoringController extends GetxController
    with WidgetsBindingObserver {
  PoultryLiveMonitoringController({PoultryLiveRepository? repository})
    : _repo = repository ?? PoultryApiLiveRepository();

  final PoultryLiveRepository _repo;

  final devices = <PoultryDevice>[].obs;
  final selectedDeviceId = ''.obs;

  final liveData = Rxn<PoultryLiveData>();
  final isLoading = false.obs;
  final error = ''.obs;

  final switchBusy = <String, bool>{}.obs;
  final switchUiState = <String, bool>{}.obs;

  Timer? _pollTimer;
  bool _isRefreshInProgress = false;
  DateTime? _lastPageVisibleRefreshAt;

  static const Duration _refreshInterval = Duration(minutes: 1);

  static const String _cacheDevicesKey = 'poultry_live_devices_cache';
  static const String _cacheLiveDataKey = 'poultry_live_data_cache';
  static const String _cacheSelectedDeviceKey = 'poultry_live_selected_device';

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadCachedState();
    _bootstrap();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (selectedDeviceId.value.isNotEmpty) {
        refreshLiveData();
        _startPolling();
      }
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _pollTimer?.cancel();
    }
  }

  Future<void> loadDevices() async {
    try {
      isLoading.value = true;
      error.value = '';

      final list = await _repo.getDevices();
      devices.assignAll(list);

      if (list.isNotEmpty) {
        switchUiState.clear();
        final cachedId = selectedDeviceId.value;
        final match = list.any((d) => d.id == cachedId);
        selectedDeviceId.value = match ? cachedId : list.first.id;
        await _cacheDevices(list);
        await _cacheSelectedDeviceId(selectedDeviceId.value);
        await refreshLiveData();
        _startPolling();
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _bootstrap() async {
    final canProceed = await _ensureLoggedIn();
    if (!canProceed) {
      if (Get.isOverlaysOpen != true) Get.back();
      return;
    }
    await loadDevices();
  }

  Future<bool> _ensureLoggedIn() async {
    final loginTokenStorage = Get.find<LoginTokenStorage>();

    if (loginTokenStorage.hasValidPoultryToken()) {
      return true;
    }

    final result = await Get.toNamed(
      Routes.POULTRY_LOGIN,
      arguments: {'fromGuard': true},
    );

    final nextToken = loginTokenStorage.getPoultryToken();
    return result == true || _hasValidToken(nextToken);
  }

  bool _hasValidToken(String? token) {
    if (token == null) return false;
    final n = token.trim().toLowerCase();
    return n.isNotEmpty && n != 'null' && n != 'undefined';
  }

  Future<void> onDeviceChanged(String deviceId) async {
    switchUiState.clear();
    selectedDeviceId.value = deviceId;
    await _cacheSelectedDeviceId(deviceId);
    await refreshLiveData();
    _startPolling();
  }

  Future<void> refreshWhenPageVisible() async {
    final now = DateTime.now();
    final last = _lastPageVisibleRefreshAt;

    if (last != null && now.difference(last) < const Duration(seconds: 2)) {
      return;
    }

    _lastPageVisibleRefreshAt = now;

    if (selectedDeviceId.value.isEmpty || devices.isEmpty) {
      await loadDevices();
      return;
    }

    await refreshLiveData();
    _startPolling();
  }

  Future<void> refreshLiveData({bool silent = false}) async {
    if (_isRefreshInProgress) return;

    final id = selectedDeviceId.value;
    if (id.isEmpty) return;

    _isRefreshInProgress = true;

    try {
      if (!silent) {
        isLoading.value = true;
      }
      error.value = '';

      final data = await _repo.getLatestLiveData(deviceId: id);
      liveData.value = data;
      _syncSwitchUiStateWithLiveData();
      await _cacheLiveData(liveData.value);

      if (Get.isRegistered<CattleHeaderController>()) {
        Get.find<CattleHeaderController>().refreshWeather(overrideId: id);
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      if (!silent) {
        isLoading.value = false;
      }
      _isRefreshInProgress = false;
    }
  }

  void openSensorGraph(PoultrySensorMetric metric) {
    final farmId = int.tryParse(selectedDeviceId.value.trim());

    if (farmId == null) {
      Get.snackbar(
        'Error',
        'Invalid farm selected',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.toNamed(
      Routes.GRAPH,
      arguments: {
        'flow': 'poultry',
        'farmId': farmId,
        'sensorKey': metric.name,
        'sensorName': metric.title,
        'unit': metric.unit,
        'type': 'daily',
      },
    );
  }

  Future<void> onSwitchChanged({
    required PoultrySwitch item,
    required bool nextValue,
  }) async {
    if (item.switchId.trim().isEmpty) return;

    final busy = switchBusy[item.switchId] ?? false;
    if (busy) return;

    switchBusy[item.switchId] = true;

    switchUiState[item.switchId] = nextValue;
    switchUiState.refresh();

    try {
      debugPrint(
        'Switch POST: ${item.switchId} -> ${nextValue ? "ON" : "OFF"}',
      );

      await _repo.setSwitchState(switchId: item.switchId, turnOn: nextValue);

      Future.delayed(
        const Duration(seconds: 2),
        () => refreshLiveData(silent: true),
      );
    } catch (e) {
      error.value = e.toString();

      switchUiState[item.switchId] = !nextValue;
      switchUiState.refresh();

      Get.snackbar(
        'Error',
        'Failed to update switch',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );

      await refreshLiveData(silent: true);
    } finally {
      switchBusy[item.switchId] = false;
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();

    _pollTimer = Timer.periodic(_refreshInterval, (_) {
      if (Get.currentRoute.toLowerCase().contains('poultry')) {
        refreshLiveData(silent: true);
      }
    });
  }

  Future<void> _loadCachedState() async {
    try {
      final storage = Get.find<LoginTokenStorage>();
      final prefs = storage.sharedPreferences;

      final cachedDevices = prefs.getString(_cacheDevicesKey);
      if (cachedDevices != null && cachedDevices.isNotEmpty) {
        final raw = jsonDecode(cachedDevices);
        if (raw is List) {
          devices.assignAll(
            raw
                .whereType<Map>()
                .map(
                  (e) => PoultryDevice.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList(),
          );
        }
      }

      final cachedDeviceId = prefs.getString(_cacheSelectedDeviceKey);
      if (cachedDeviceId != null && cachedDeviceId.trim().isNotEmpty) {
        selectedDeviceId.value = cachedDeviceId;
      } else if (devices.isNotEmpty) {
        selectedDeviceId.value = devices.first.id;
      }

      final cachedLiveData = prefs.getString(_cacheLiveDataKey);
      if (cachedLiveData != null && cachedLiveData.isNotEmpty) {
        final raw = jsonDecode(cachedLiveData);
        if (raw is Map) {
          liveData.value = PoultryLiveData.fromJson(
            Map<String, dynamic>.from(raw),
          );
          _syncSwitchUiStateWithLiveData();
        }
      }
    } catch (_) {}
  }

  Future<void> _cacheDevices(List<PoultryDevice> list) async {
    final storage = Get.find<LoginTokenStorage>();
    final prefs = storage.sharedPreferences;
    final payload = jsonEncode(list.map((d) => d.toJson()).toList());
    await prefs.setString(_cacheDevicesKey, payload);
  }

  Future<void> _cacheSelectedDeviceId(String deviceId) async {
    final storage = Get.find<LoginTokenStorage>();
    final prefs = storage.sharedPreferences;
    await prefs.setString(_cacheSelectedDeviceKey, deviceId.trim());
  }

  Future<void> _cacheLiveData(PoultryLiveData? data) async {
    if (data == null) return;
    final storage = Get.find<LoginTokenStorage>();
    final prefs = storage.sharedPreferences;
    final payload = Map<String, dynamic>.from(data.toJson());
    await prefs.setString(_cacheLiveDataKey, jsonEncode(payload));
  }

  void _syncSwitchUiStateWithLiveData() {
    final switches = liveData.value?.switches ?? const <PoultrySwitch>[];
    if (switches.isEmpty) {
      switchUiState.clear();
      return;
    }

    final nextState = <String, bool>{};
    for (final sw in switches) {
      nextState[sw.switchId] = sw.isOn;
    }
    switchUiState.assignAll(nextState);
  }
}
