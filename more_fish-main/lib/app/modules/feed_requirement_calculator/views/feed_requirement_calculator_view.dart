import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common_widgets/common_container.dart';
import '../../../common_widgets/common_text.dart';
import '../../../res/colors/colors.dart';
import '../controllers/feed_requirement_calculator_controller.dart';

class FeedRequirementCalculatorView
    extends GetView<FeedRequirementCalculatorController> {
  const FeedRequirementCalculatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGround,
      appBar: AppBar(
        title: Text('feed_requirement_calculator'.tr),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            CommonContainer(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    'feed_requirement_calculator'.tr,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  const SizedBox(height: 14),
                  CommonText(
                    'select_fish_size'.tr,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.selectedSize.value,
                            isExpanded: true,
                            items: controller.fishSizes.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value.tr),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              if (newValue != null) {
                                controller.selectedSize.value = newValue;
                              }
                            },
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),
                  _numberInputField(
                    controller: controller.bodyWeightController,
                    label: 'total_body_weight'.tr,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: controller.calculateRequirement,
                          child: Text('calculate'.tr),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: controller.clearAll,
                          child: Text('clear'.tr),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (controller.validationMessage.value.isNotEmpty) {
                      return Text(
                        controller.validationMessage.value.tr,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }

                    final value = controller.feedRequirementResult.value;
                    if (value == null) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xffe8f7ff),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xffb2dbef)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText(
                            'result'.tr,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          const SizedBox(height: 4),
                          CommonText(
                            '${'required_feed'.tr} = ${value.toStringAsFixed(2)} kg',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xff0370c3),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberInputField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.6),
        ),
      ),
    );
  }
}
