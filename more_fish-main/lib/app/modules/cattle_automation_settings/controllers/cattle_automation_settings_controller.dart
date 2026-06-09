import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../repo/cattle_live_repo.dart';
import '../../../response/cattle_automation_response.dart';

class CattleAutomationSettingsController extends GetxController {
  final CattleLiveDataRepository _repo = CattleLiveDataRepository();

  final isLoading = false.obs;
  final isSaving = false.obs;
  final isAutomationEnabled = false.obs;

  final fanTempMinController = TextEditingController();
  final fanTempMaxController = TextEditingController();
  final foggerHumidityMinController = TextEditingController();

  final lightSchedules = <LightSchedule>[].obs;

  int? farmId;

  // Tracking original values for unsaved changes detection
  bool? _originalEnabled;
  String _originalFanMin = "";
  String _originalFanMax = "";
  String _originalFoggerMin = "";
  List<String> _originalSchedules = [];

  bool get hasUnsavedChanges {
    final currentSchedules = lightSchedules.map((s) => "${s.startTime}-${s.endTime}").toList();
    
    return isAutomationEnabled.value != _originalEnabled ||
           fanTempMinController.text != _originalFanMin ||
           fanTempMaxController.text != _originalFanMax ||
           foggerHumidityMinController.text != _originalFoggerMin ||
           !_areListsEqual(currentSchedules, _originalSchedules);
  }

  bool _areListsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['farmId'] != null) {
      farmId = int.tryParse(args['farmId'].toString());
      if (farmId != null) {
        fetchAutomationSettings();
      }
    }
  }

  Future<void> fetchAutomationSettings() async {
    if (farmId == null) return;

    isLoading.value = true;
    final response = await _repo.getAutomationSettings(farmId: farmId!);
    response.fold(
      (l) {
        debugPrint('Fetch Error: ${l.message}');
      },
      (r) {
        if (r.data != null) {
          isAutomationEnabled.value = r.data!.isEnabled ?? false;
          fanTempMinController.text = r.data!.fanTempMin?.toString() ?? '';
          fanTempMaxController.text = r.data!.fanTempMax?.toString() ?? '';
          foggerHumidityMinController.text = r.data!.foggerHumidityMin?.toString() ?? '';
          lightSchedules.assignAll(r.data!.lightSchedules ?? []);

          _captureOriginalState();
        }
      },
    );
    isLoading.value = false;
  }

  void _captureOriginalState() {
    _originalEnabled = isAutomationEnabled.value;
    _originalFanMin = fanTempMinController.text;
    _originalFanMax = fanTempMaxController.text;
    _originalFoggerMin = foggerHumidityMinController.text;
    _originalSchedules = lightSchedules.map((s) => "${s.startTime}-${s.endTime}").toList();
  }

  Future<void> saveSettings() async {
    if (farmId == null) return;

    final fanMin = double.tryParse(fanTempMinController.text);
    final fanMax = double.tryParse(fanTempMaxController.text);
    final foggerMin = double.tryParse(foggerHumidityMinController.text);

    isSaving.value = true;
    final response = await _repo.saveAutomationSettings(
      farmId: farmId!,
      isEnabled: isAutomationEnabled.value,
      fanTempMin: fanMin,
      fanTempMax: fanMax,
      foggerHumidityMin: foggerMin,
    );

    response.fold(
      (l) {
        _showSnackbar('Error', l.message, Colors.redAccent);
      },
      (r) {
        _showSnackbar('Success', r.message ?? 'Settings saved', Colors.green);
        if (r.data != null) {
          isAutomationEnabled.value = r.data!.isEnabled ?? false;
          fanTempMinController.text = r.data!.fanTempMin?.toString() ?? '';
          fanTempMaxController.text = r.data!.fanTempMax?.toString() ?? '';
          foggerHumidityMinController.text = r.data!.foggerHumidityMin?.toString() ?? '';
          lightSchedules.assignAll(r.data!.lightSchedules ?? []);
          _captureOriginalState();
        }
      },
    );
    isSaving.value = false;
  }

  Future<void> addLightSchedule(String start, String end) async {
    if (farmId == null) return;

    isLoading.value = true;
    final response = await _repo.addLightSchedule(
      farmId: farmId!,
      startTime: start,
      endTime: end,
    );

    response.fold(
      (l) => _showSnackbar('Error', l.message, Colors.redAccent),
      (r) => fetchAutomationSettings(),
    );
  }

  Future<void> deleteLightSchedule(int scheduleId) async {
    isLoading.value = true;
    final response = await _repo.deleteLightSchedule(scheduleId: scheduleId);

    response.fold(
      (l) => _showSnackbar('Error', l.message, Colors.redAccent),
      (r) => fetchAutomationSettings(),
    );
  }

  void _showSnackbar(String title, String message, Color color) {
    final context = Get.context;

    if (context == null) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void onClose() {
    fanTempMinController.dispose();
    fanTempMaxController.dispose();
    foggerHumidityMinController.dispose();
    super.onClose();
  }
}
