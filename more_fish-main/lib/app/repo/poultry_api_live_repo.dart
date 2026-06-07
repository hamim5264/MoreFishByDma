import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:dartz/dartz.dart';

import '../service/service.dart';
import '../service/local_storage.dart';
import '../service/failure.dart';
import '../response/poultry_automation_response.dart';
import 'poultry_live_models.dart';
import 'poultry_live_repo.dart';

class PoultryApiLiveRepository implements PoultryLiveRepository {
  static const String _fallbackBearerToken =
      '21067c389d5d27d6ecfd22dc13e0ccb792714ad6';

  static const String _poultryBaseUrl = ApiService.poultryBaseUrl;

  Uri get _farmListUri =>
      Uri.parse('$_poultryBaseUrl/poultry_care/farms/list/');

  Uri _farmDashboardUri(int farmId) => Uri.parse(
        '$_poultryBaseUrl/poultry_care/farms/dashboard/?farm_id=$farmId',
      );

  Uri get _switchCommandUri =>
      Uri.parse('$_poultryBaseUrl/poultry_care/switches/command/');

  Uri get _automationUri =>
      Uri.parse('$_poultryBaseUrl/poultry_care/automation/');

  Uri get _lightScheduleUri =>
      Uri.parse('$_poultryBaseUrl/poultry_care/automation/light-schedule/');

  @override
  Future<List<PoultryDevice>> getDevices() async {
    final farms = await _fetchFarmList();
    return farms.map(_toFarmDevice).toList();
  }

  @override
  Future<PoultryLiveData> getLatestLiveData({required String deviceId}) async {
    final farmId = int.tryParse(deviceId.trim());
    if (farmId == null) {
      throw Exception('Invalid farm id: $deviceId');
    }

    final dashboard = await _fetchFarmDashboard(farmId: farmId);

    return _toLiveDataFromDashboard(
      dashboardData: dashboard,
      selectedDeviceId: deviceId,
    );
  }

  @override
  Future<void> setSwitchState({
    required String switchId,
    required bool turnOn,
  }) async {
    final token = _getToken();
    final body = jsonEncode({'switch_id': switchId, 'command': turnOn ? 1 : 0});

    final response = await http.post(
      _switchCommandUri,
      headers: _headers(token),
      body: body,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Switch command failed with status ${response.statusCode}',
      );
    }
  }

  @override
  Future<Either<Failure, PoultryAutomationResponse>> getAutomationSettings({
    required int farmId,
  }) async {
    try {
      final token = _getToken();
      final uri = Uri.parse('$_automationUri?farm_id=$farmId');
      final response = await http.get(uri, headers: _headers(token));

      if (response.statusCode == 200) {
        return Right(PoultryAutomationResponse.fromRawJson(response.body));
      } else {
        return Left(Failure(
          'Failed to fetch automation settings: ${response.statusCode}',
        ));
      }
    } catch (e) {
      return Left(Failure('Error: $e'));
    }
  }

  @override
  Future<Either<Failure, PoultryAutomationResponse>> saveAutomationSettings({
    required int farmId,
    required bool isEnabled,
    double? fanTempMin,
    double? fanTempMax,
    double? foggerHumidityMin,
  }) async {
    try {
      final token = _getToken();
      final body = jsonEncode({
        "farm_id": farmId,
        "is_enabled": isEnabled,
        if (fanTempMin != null) "fan_temp_min": fanTempMin,
        if (fanTempMax != null) "fan_temp_max": fanTempMax,
        if (foggerHumidityMin != null) "fogger_humidity_min": foggerHumidityMin,
      });

      final response = await http.post(
        _automationUri,
        headers: _headers(token),
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(PoultryAutomationResponse.fromRawJson(response.body));
      } else {
        return Left(Failure(
          'Failed to save automation settings: ${response.statusCode}',
        ));
      }
    } catch (e) {
      return Left(Failure('Error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> addLightSchedule({
    required int farmId,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final token = _getToken();
      final body = jsonEncode({
        "farm_id": farmId,
        "start_time": startTime,
        "end_time": endTime,
      });

      final response = await http.post(
        _lightScheduleUri,
        headers: _headers(token),
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(true);
      } else {
        return Left(Failure('Failed to add light schedule: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(Failure('Error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteLightSchedule({
    required int scheduleId,
  }) async {
    try {
      final token = _getToken();
      final uri = Uri.parse('$_lightScheduleUri$scheduleId/');
      final response = await http.delete(uri, headers: _headers(token));

      if (response.statusCode == 200) {
        return const Right(true);
      } else {
        return Left(Failure(
          'Failed to delete light schedule: ${response.statusCode}',
        ));
      }
    } catch (e) {
      return Left(Failure('Error: $e'));
    }
  }

  Future<List<Map<String, dynamic>>> _fetchFarmList() async {
    final token = _getToken();
    final response = await http.get(_farmListUri, headers: _headers(token));

    if (response.statusCode != 200) {
      throw Exception(
        'Farm list API failed with status ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);
    return (decoded['data'] as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<Map<String, dynamic>> _fetchFarmDashboard({
    required int farmId,
  }) async {
    final token = _getToken();
    final uri = _farmDashboardUri(farmId);
    final response = await http.get(uri, headers: _headers(token));

    if (response.statusCode != 200) {
      throw Exception(
        'Farm dashboard API failed with status ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);
    return Map<String, dynamic>.from(decoded['data']);
  }

  PoultryDevice _toFarmDevice(Map<String, dynamic> farm) {
    return PoultryDevice(
      id: farm['id'].toString(),
      name: (farm['name'] ?? farm['location'] ?? 'Farm ${farm['id']}').toString(),
    );
  }

  PoultryLiveData _toLiveDataFromDashboard({
    required Map<String, dynamic> dashboardData,
    required String selectedDeviceId,
  }) {
    final device = dashboardData['device'] as Map<String, dynamic>;
    final sensors = (device['sensors'] as List).cast<Map<String, dynamic>>();

    double val(String name) {
      final s = sensors.firstWhere((s) => s['name'].toString().toLowerCase() == name.toLowerCase(), orElse: () => {});
      return double.tryParse(s['last_value']?.toString() ?? '0') ?? 0.0;
    }

    return PoultryLiveData(
      deviceId: selectedDeviceId,
      deviceStatus: device['device_status']?.toString() ?? '',
      isOnline: device['is_online'] == true,
      timestamp: DateFormat('dd MMM yyyy hh:mm a').format(DateTime.now()),
      nh3MgL: val('nh3_gas'),
      temperatureC: val('temperature'),
      humidityPct: val('humidity').round(),
      vocMgM3: val('tvoc'),
      co2Ppm: val('co2').round(),
      ch4Ppm: val('methane_ppm').round(),
      pm1UgM3: val('pm1_0').round(),
      pm25UgM3: val('pm2_5').round(),
      pm4UgM3: val('pm4_0').round(),
      pm10UgM3: val('pm10').round(),
      noiseDb: val('sound_db').round(),
      lightLux: val('light_intensity').round(),
      automationEnabled: dashboardData['automation_enabled'] == true,
      metrics: sensors.map((s) => PoultrySensorMetric.fromJson(s)).toList(),
      switches: (device['switches'] as List).map((sw) => PoultrySwitch.fromJson(sw)).toList(),
    );
  }

  String _getToken() {
    final storage = Get.find<LoginTokenStorage>();
    return storage.getPoultryToken() ?? _fallbackBearerToken;
  }

  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
