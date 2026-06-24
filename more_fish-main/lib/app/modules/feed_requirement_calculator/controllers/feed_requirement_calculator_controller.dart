import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeedRequirementCalculatorController extends GetxController {
  final bodyWeightController = TextEditingController();

  final selectedSize = 'fry_fingerling'.obs;
  final feedRequirementResult = RxnDouble();
  final validationMessage = ''.obs;

  final List<String> fishSizes = [
    'fry_fingerling',
    'medium_size',
    'market_size',
  ];

  void calculateRequirement() {
    final bodyWeight = double.tryParse(bodyWeightController.text.trim());

    if (bodyWeight == null) {
      validationMessage.value = 'enter_numeric_values';
      feedRequirementResult.value = null;
      return;
    }

    if (bodyWeight <= 0) {
      validationMessage.value = 'values_greater_than_zero';
      feedRequirementResult.value = null;
      return;
    }

    validationMessage.value = '';

    double percentage = 0;
    switch (selectedSize.value) {
      case 'fry_fingerling':
        percentage = 8.0;
        break;
      case 'medium_size':
        percentage = 4.0;
        break;
      case 'market_size':
        percentage = 2.5;
        break;
    }

    feedRequirementResult.value = (percentage * bodyWeight) / 100;
  }

  void clearAll() {
    bodyWeightController.clear();
    selectedSize.value = 'fry_fingerling';
    validationMessage.value = '';
    feedRequirementResult.value = null;
  }

  @override
  void onClose() {
    bodyWeightController.dispose();
    super.onClose();
  }
}
