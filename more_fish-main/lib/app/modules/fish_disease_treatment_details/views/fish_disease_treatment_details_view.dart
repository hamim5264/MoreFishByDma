import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:more_fish/app/res/colors/colors.dart';

import '../../../common_widgets/common_container.dart';
import '../../../common_widgets/common_text.dart';
import '../controllers/fish_disease_treatment_details_controller.dart';

class FishDiseaseTreatmentDetailsView
    extends GetView<FishDiseaseTreatmentDetailsController> {
  const FishDiseaseTreatmentDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGround,
      appBar: AppBar(
        backgroundColor: const Color(0xffcbffff),
        title: Text(
          (controller.title).tr,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: CommonContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: ListView.builder(
          itemCount: controller.data.length,
          itemBuilder: (context, index) {
            final String itemText = controller.data[index].toString();
            return Column(
              children: [
                itemText == "Causes:" ||
                        itemText == "Symptoms:" ||
                        itemText == "Treatment:" ||
                        itemText == "Prevention:"
                    ? Row(
                        children: [
                          Expanded(
                            child: CommonText(
                              itemText.tr,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              maxLines: 3,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: CommonText(
                              itemText.tr,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              maxLines: 20,
                            ),
                          ),
                        ],
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}
