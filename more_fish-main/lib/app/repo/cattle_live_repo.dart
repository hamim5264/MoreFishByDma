import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';

import '../response/cattle_automation_response.dart';
import '../response/cattle_farm_list_response.dart';
import '../response/cattle_farrm_dashboard_response.dart';
import '../response/cattle_notifications_response.dart';
import '../service/failure.dart';
import '../service/service.dart';
import '../service/local_storage.dart';
import 'cattle_live_models.dart';

abstract class CattleLiveRepository {
  Future<List<CattleDevice>> getDevices();

  Future<CattleLiveData> getLatestLiveData({required String deviceId});
}

class CattleLiveDataRepository {
  static const Duration _timeout = Duration(seconds: 30);

  Future<Either<Failure, CattleFarmListResponse>> getFarmList() async {
    final storage = Get.find<LoginTokenStorage>();
    final token = storage.getCattleToken();
    final url = Uri.parse("${ApiService.baseUrl}/cattle_care/farms/list/");

    debugPrint('Cattle GET FarmList: $url');

    try {
      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(_timeout);

      debugPrint('Cattle FarmList status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return Right(CattleFarmListResponse.fromRawJson(response.body));
      } else {
        return Left(Failure('Server returned status: ${response.statusCode}'));
      }
    } on SocketException {
      return Left(Failure('No internet connection'));
    } on TimeoutException {
      return Left(Failure('Connection timed out'));
    } catch (e) {
      return Left(Failure('Error: $e'));
    }
  }

  Future<Either<Failure, CattleFarmDashboardResponse>> getFarmDashboard({
    required String id,
  }) async {
    final storage = Get.find<LoginTokenStorage>();
    final token = storage.getCattleToken();
    final url = Uri.parse(
      "${ApiService.baseUrl}/cattle_care/farms/dashboard/?farm_id=$id",
    );

    debugPrint('Cattle GET Dashboard: $url');

    try {
      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(_timeout);

      debugPrint('Cattle Dashboard status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return Right(CattleFarmDashboardResponse.fromRawJson(response.body));
      } else {
        return Left(Failure('Server returned status: ${response.statusCode}'));
      }
    } on SocketException {
      return Left(Failure('No internet connection'));
    } on TimeoutException {
      return Left(Failure('Connection timed out'));
    } catch (e) {
      return Left(Failure('Error: $e'));
    }
  }

  Future<Either<Failure, CattleNotificationsResponse>>
  getNotifications() async {
    final storage = Get.find<LoginTokenStorage>();
    final token = storage.getCattleToken();
    final url = Uri.parse("${ApiService.baseUrl}/cattle_care/notifications/");

    try {
      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return Right(CattleNotificationsResponse.fromRawJson(response.body));
      } else {
        return Left(Failure('Server error: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(Failure('Error: $e'));
    }
  }

  Future<Either<Failure, bool>> setSwitchState({
    required String switchId,
    required bool turnOn,
  }) async {
    final storage = Get.find<LoginTokenStorage>();
    final token = storage.getCattleToken();
    final url = Uri.parse(
      "${ApiService.baseUrl}/cattle_care/switches/command/",
    );

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'switch_id': switchId,
              'command': turnOn ? 1 : 0,
            }),
          )
          .timeout(_timeout);

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 403) {
        if (decoded['success'] == true) {
          return const Right(true);
        } else {
          return Left(Failure(decoded['message'] ?? 'Switch command failed'));
        }
      } else {
        return Left(
          Failure(decoded['message'] ?? 'Server error: ${response.statusCode}'),
        );
      }
    } catch (e) {
      return Left(Failure('Error: $e'));
    }
  }

  Future<Either<Failure, CattleAutomationResponse>> getAutomationSettings({
    required int farmId,
  }) async {
    final storage = Get.find<LoginTokenStorage>();
    final token = storage.getCattleToken();
    final url = Uri.parse(
      "${ApiService.baseUrl}/cattle_care/automation/?farm_id=$farmId",
    );

    try {
      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return Right(CattleAutomationResponse.fromRawJson(response.body));
      } else {
        return Left(Failure('Server error: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(Failure('Error: $e'));
    }
  }

  Future<Either<Failure, CattleAutomationResponse>> saveAutomationSettings({
    required int farmId,
    required bool isEnabled,
    double? fanTempMin,
    double? fanTempMax,
    double? foggerHumidityMin,
  }) async {
    final storage = Get.find<LoginTokenStorage>();
    final token = storage.getCattleToken();
    final url = Uri.parse("${ApiService.baseUrl}/cattle_care/automation/");

    try {
      final body = {
        "farm_id": farmId,
        "is_enabled": isEnabled,
        if (fanTempMin != null) "fan_temp_min": fanTempMin,
        if (fanTempMax != null) "fan_temp_max": fanTempMax,
        if (foggerHumidityMin != null) "fogger_humidity_min": foggerHumidityMin,
      };

      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(CattleAutomationResponse.fromRawJson(response.body));
      } else {
        return Left(Failure('Server error: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(Failure('Error: $e'));
    }
  }

  Future<Either<Failure, bool>> addLightSchedule({
    required int farmId,
    required String startTime,
    required String endTime,
  }) async {
    final storage = Get.find<LoginTokenStorage>();
    final token = storage.getCattleToken();
    final url = Uri.parse(
      "${ApiService.baseUrl}/cattle_care/automation/light-schedule/",
    );

    try {
      final body = {
        "farm_id": farmId,
        "start_time": startTime,
        "end_time": endTime,
      };

      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(true);
      } else {
        return Left(Failure('Server error: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(Failure('Error: $e'));
    }
  }

  Future<Either<Failure, bool>> deleteLightSchedule({
    required int scheduleId,
  }) async {
    final storage = Get.find<LoginTokenStorage>();
    final token = storage.getCattleToken();
    final url = Uri.parse(
      "${ApiService.baseUrl}/cattle_care/automation/light-schedule/$scheduleId/",
    );

    try {
      final response = await http
          .delete(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return const Right(true);
      } else {
        return Left(Failure('Server error: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(Failure('Error: $e'));
    }
  }
}
