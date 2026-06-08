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
    final device = _map(dashboardData['device']);
    final sensorsRaw = device['sensors'];
    final sensors = sensorsRaw is List
        ? sensorsRaw.whereType<Map>().map((e) => _map(e)).toList()
        : const <Map<String, dynamic>>[];

    final values = _extractSensorValues(sensors);

    final resolvedDeviceId = _firstNonEmpty([
      _string(device['client_id']),
      _string(device['device_name']),
      _string(dashboardData['farm_name']),
      selectedDeviceId,
    ]);

    final ts = _firstNonEmpty([
      _string(_sensorValueByName(sensors, 'temperature', field: 'data_time')),
      _string(_sensorValueByName(sensors, 'humidity', field: 'data_time')),
      DateFormat('dd MMM yyyy hh:mm a').format(DateTime.now()),
    ]);

    return PoultryLiveData(
      deviceId: resolvedDeviceId.isEmpty ? selectedDeviceId : resolvedDeviceId,
      deviceStatus: _string(device['device_status']),
      isOnline: device['is_online'] == true,
      timestamp: ts,
      aqi: _double(values['aqi']),
      nh3MgL: _double(values['nh3_gas']),
      temperatureC: _double(values['temperature']),
      refTemperatureC: null,
      humidityPct: _double(values['humidity']).round(),
      vocMgM3: _double(values['tvoc']),
      co2Ppm: _double(values['co2']).round(),
      ch4Ppm: _double(values['methane_ppm']).round(),
      pm1UgM3: _double(values['pm1_0']).round(),
      pm25UgM3: _double(values['pm2_5']).round(),
      pm4UgM3: _double(values['pm4_0']).round(),
      pm10UgM3: _double(values['pm10']).round(),
      noiseDb: _double(values['sound_db']).round(),
      lightLux: _double(values['light_intensity']).round(),
      automationEnabled: dashboardData['automation_enabled'] == true,
      metrics: _extractAllMetrics(sensors),
      switches: _extractSwitches(dashboardData),
    );
  }

  Map<String, double> _extractSensorValues(List<Map<String, dynamic>> sensors) {
    final result = <String, double>{};

    double valueOf(String name) {
      return _double(_sensorValueByName(sensors, name, field: 'last_value'));
    }

    result['temperature'] = valueOf('temperature');
    result['humidity'] = valueOf('humidity');
    result['co2'] = valueOf('co2');
    result['nh3_gas'] = valueOf('nh3_gas');
    result['aqi'] = valueOf('aqi');
    result['sound_db'] = valueOf('sound_db');
    result['tvoc'] = valueOf('tvoc');
    result['methane_ppm'] = valueOf('methane_ppm');
    result['light_intensity'] = valueOf('light_intensity');
    result['pm1_0'] = valueOf('pm1_0');
    result['pm2_5'] = valueOf('pm2_5');
    result['pm4_0'] = valueOf('pm4_0');
    result['pm10'] = valueOf('pm10');

    return result;
  }

  List<PoultrySensorMetric> _extractAllMetrics(
    List<Map<String, dynamic>> sensors,
  ) {
    return sensors.map((sensor) {
      final rawName = _string(sensor['name']);
      final normalizedName = rawName.trim().toLowerCase();
      return PoultrySensorMetric(
        name: normalizedName,
        title: _metricTitle(normalizedName),
        unit: _string(sensor['unit']),
        value: _double(sensor['last_value']),
        dangerStatus: _string(sensor['danger_status']),
        dataTime: _string(sensor['data_time']),
      );
    }).toList();
  }

  String _metricTitle(String normalizedName) {
    switch (normalizedName) {
      case 'aqi':
        return 'AQI';
      case 'nh3_gas':
        return 'Ammonia (NH3)';
      case 'co2':
        return 'Carbon dioxide';
      case 'tvoc':
        return 'TVOC';
      case 'sound_db':
        return 'Sound';
      case 'methane_ppm':
        return 'Methane (CH4)';
      case 'light_intensity':
        return 'Light intensity';
      case 'pm1_0':
        return 'PM 1.0';
      case 'pm2_5':
        return 'PM 2.5';
      case 'pm4_0':
        return 'PM 4.0';
      case 'pm10':
        return 'PM 10';
      default:
        return normalizedName
            .split('_')
            .where((e) => e.isNotEmpty)
            .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
            .join(' ');
    }
  }

  dynamic _sensorValueByName(
    List<Map<String, dynamic>> sensors,
    String name, {
    required String field,
  }) {
    final normalized = name.trim().toLowerCase();
    for (final sensor in sensors) {
      final sensorName = _string(sensor['name']).trim().toLowerCase();
      if (sensorName == normalized) {
        return sensor[field];
      }
    }
    return null;
  }

  List<PoultrySwitch> _extractSwitches(Map<String, dynamic> dashboardData) {
    final device = _map(dashboardData['device']);
    final switchesRaw = device['switches'];
    if (switchesRaw is! List) {
      return const <PoultrySwitch>[];
    }

    return switchesRaw
        .whereType<Map>()
        .map((e) => PoultrySwitch.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  String _getToken() {
    if (Get.isRegistered<LoginTokenStorage>()) {
      final token = Get.find<LoginTokenStorage>().getPoultryToken();
      if (_isValidToken(token)) {
        return token!.trim();
      }
    }

    debugPrint('Poultry API token missing in storage, using fallback token.');
    return _fallbackBearerToken;
  }

  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  String _firstNonEmpty(List<String> values) {
    for (final item in values) {
      if (item.trim().isNotEmpty) {
        return item;
      }
    }
    return '';
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  String _string(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  bool _isValidToken(String? token) {
    if (token == null) return false;
    final normalized = token.trim().toLowerCase();
    return normalized.isNotEmpty &&
        normalized != 'null' &&
        normalized != 'undefined';
  }

  double _double(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0.0;
  }
}
