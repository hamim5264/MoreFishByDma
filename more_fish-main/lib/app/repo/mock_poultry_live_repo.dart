import 'package:dartz/dartz.dart';
import 'poultry_live_models.dart';
import 'poultry_live_repo.dart';
import '../response/poultry_automation_response.dart';
import '../service/failure.dart';

class MockPoultryLiveRepository implements PoultryLiveRepository {
  @override
  Future<List<PoultryDevice>> getDevices() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [PoultryDevice(id: 'Jessore-DMA03', name: 'Jessore-DMA03')];
  }

  @override
  Future<PoultryLiveData> getLatestLiveData({required String deviceId}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return PoultryLiveData(
      deviceId: deviceId,
      deviceStatus: 'online',
      timestamp: DateTime.now().toIso8601String(),
      nh3MgL: 0.02,
      temperatureC: 28.5,
      humidityPct: 70,
      vocMgM3: 0.1,
      co2Ppm: 400,
      ch4Ppm: 10,
      pm1UgM3: 5,
      pm25UgM3: 10,
      pm4UgM3: 15,
      pm10UgM3: 20,
      noiseDb: 60,
      lightLux: 100,
      switches: [],
    );
  }

  @override
  Future<void> setSwitchState({
    required String switchId,
    required bool turnOn,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<Either<Failure, PoultryAutomationResponse>> getAutomationSettings({
    required int farmId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Right(
      PoultryAutomationResponse(
        success: true,
        data: PoultryAutomationData(
          id: 1,
          farm: farmId,
          isEnabled: false,
          fanTempMin: 20.0,
          fanTempMax: 35.0,
          foggerHumidityMin: 40.0,
          lightSchedules: [],
          updatedAt: DateTime.now(),
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, PoultryAutomationResponse>> saveAutomationSettings({
    required int farmId,
    required bool isEnabled,
    double? fanTempMin,
    double? fanTempMax,
    double? foggerHumidityMin,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Right(
      PoultryAutomationResponse(
        success: true,
        data: PoultryAutomationData(
          id: 1,
          farm: farmId,
          isEnabled: isEnabled,
          fanTempMin: fanTempMin ?? 20.0,
          fanTempMax: fanTempMax ?? 35.0,
          foggerHumidityMin: foggerHumidityMin ?? 40.0,
          lightSchedules: [],
          updatedAt: DateTime.now(),
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, bool>> addLightSchedule({
    required int farmId,
    required String startTime,
    required String endTime,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> deleteLightSchedule({
    required int scheduleId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const Right(true);
  }
}
