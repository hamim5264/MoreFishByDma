import 'package:dartz/dartz.dart';
import '../response/poultry_automation_response.dart';
import '../service/failure.dart';
import 'poultry_live_models.dart';

abstract class PoultryLiveRepository {
  Future<List<PoultryDevice>> getDevices();
  Future<PoultryLiveData> getLatestLiveData({required String deviceId});
  Future<void> setSwitchState({required String switchId, required bool turnOn});

  Future<Either<Failure, PoultryAutomationResponse>> getAutomationSettings({
    required int farmId,
  });

  Future<Either<Failure, PoultryAutomationResponse>> saveAutomationSettings({
    required int farmId,
    required bool isEnabled,
    double? fanTempMin,
    double? fanTempMax,
    double? foggerHumidityMin,
  });

  Future<Either<Failure, bool>> addLightSchedule({
    required int farmId,
    required String startTime,
    required String endTime,
  });

  Future<Either<Failure, bool>> deleteLightSchedule({
    required int scheduleId,
  });
}
