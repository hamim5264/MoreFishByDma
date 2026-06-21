import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../repo/devices_repo.dart';
import '../../../response/fcr_history_response.dart';
import '../../../service/local_storage.dart';
import '../../../service/service.dart';

class FcrCalculatorController extends GetxController {
  final feedAmountController = TextEditingController();
  final weightGainController = TextEditingController();

  final DevicesRepository _devicesRepository = DevicesRepository();
  final LoginTokenStorage _loginTokenStorage = Get.find<LoginTokenStorage>();

  final assetId = RxnInt();
  final assetName = ''.obs;
  final ponds = <dynamic>[].obs;
  final fcrResult = RxnDouble();
  final validationMessage = ''.obs;
  
  final fcrHistory = <FcrRecord>[].obs;
  final isLoadingHistory = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAssetId();
  }

  Future<void> _loadAssetId() async {
    final result = await _devicesRepository.getPondList();
    result.fold(
      (failure) {
        assetId.value = null;
        validationMessage.value = failure.message;
      },
      (pondList) {
        if (pondList.data.isEmpty) {
          assetId.value = null;
          validationMessage.value = 'no_assets_found';
          return;
        }

        ponds.value = pondList.data;
        selectAsset(pondList.data.first.id, pondList.data.first.astName);
      },
    );
  }

  void selectAsset(int id, String name) {
    assetId.value = id;
    assetName.value = name;
    fetchFcrHistory();
  }

  Future<void> fetchFcrHistory() async {
    final id = assetId.value;
    if (id == null) return;

    isLoadingHistory.value = true;
    final result = await _devicesRepository.getFcrHistory(assetId: id);
    isLoadingHistory.value = false;

    result.fold(
      (failure) => debugPrint('Error fetching FCR history: ${failure.message}'),
      (history) {
        fcrHistory.value = history.data;
      },
    );
  }

  Future<void> calculateFcr() async {
    final feedAmount = double.tryParse(feedAmountController.text.trim());
    final weightGain = double.tryParse(weightGainController.text.trim());

    if (feedAmount == null || weightGain == null) {
      validationMessage.value = 'enter_numeric_values';
      fcrResult.value = null;
      return;
    }

    if (feedAmount <= 0 || weightGain <= 0) {
      validationMessage.value = 'values_greater_than_zero';
      fcrResult.value = null;
      return;
    }

    final selectedAssetId = assetId.value;
    if (selectedAssetId == null) {
      validationMessage.value = 'asset_not_available';
      fcrResult.value = null;
      return;
    }

    final token = _loginTokenStorage.getMoreFishToken();
    if (token == null || token.isEmpty) {
      validationMessage.value = 'missing_auth_token';
      fcrResult.value = null;
      return;
    }

    validationMessage.value = '';

    try {
      final request = http.Request(
        'POST',
        Uri.parse("${ApiService.baseUrl}/devices/fcr/calculate/"),
      );
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
      request.body = jsonEncode({
        'asset_id': selectedAssetId,
        'feed_weight_kg': feedAmount,
        'weight_gained_kg': weightGain,
        'notes': 'Optional label',
      });

      final response = await request.send();
      final rawBody = await response.stream.bytesToString();
      debugPrint('FCR API status: ${response.statusCode}');
      debugPrint('FCR API body: $rawBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(rawBody);
        final data = decoded is Map<String, dynamic>
            ? decoded['data'] as Map<String, dynamic>?
            : null;
        final fcrValue = data?['fcr'];

        if (fcrValue is num) {
          fcrResult.value = fcrValue.toDouble();
          fetchFcrHistory(); // Refresh history after calculation
          return;
        }

        fcrResult.value = null;
        validationMessage.value = 'fcr_value_missing';
        return;
      }

      fcrResult.value = null;
      validationMessage.value = 'fcr_calc_failed';
    } catch (e) {
      fcrResult.value = null;
      validationMessage.value = 'Error: $e';
    }
  }

  void clearAll() {
    feedAmountController.clear();
    weightGainController.clear();
    validationMessage.value = '';
    fcrResult.value = null;
  }

  @override
  void onClose() {
    feedAmountController.dispose();
    weightGainController.dispose();
    super.onClose();
  }
}
