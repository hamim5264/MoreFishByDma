import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:more_fish/app/common_widgets/common_container.dart';
import '../../../common_widgets/common_app_bar.dart';
import '../../../common_widgets/common_text.dart';
import '../../../res/colors/colors.dart';
import '../../../res/strings/pond_management.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/pond_management_details_controller.dart';

class PondManagementDetailsView
    extends GetView<PondManagementDetailsController> {
  const PondManagementDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.put(HomeController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xffd4fcfd),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backGround,
        body: Column(
          children: [
            const SizedBox(height: 20),
            Obx(() {
              return CommonAppBar(
                title: 'title'.tr,
                cityName: "dhaka".tr,
                date: '${homeController.formattedDate}',
                time: '${homeController.formattedTime}',
                temp: '${homeController.weatherData['main']['temp']}°C',
                humidity: '${homeController.weatherData['main']['humidity']}%',
              );
            }),
            Obx(() {
              return Expanded(
                child: Column(
                  children: [
                    if (controller.title.value == "Steps for Fish Farming")
                      Column(
                        children: [
                          CommonContainer(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                section(text: PondManagementData.title2Value1),
                                section(text: PondManagementData.title2Value2),
                                section(text: PondManagementData.title2Value3),
                                section(text: PondManagementData.title2Value4),
                                section(text: PondManagementData.title2Value5),
                                section(text: PondManagementData.title2Value6),
                                section(text: PondManagementData.title2Value7),
                                section(text: PondManagementData.title2Value8),
                                section(text: PondManagementData.title2Value9),
                                section(text: PondManagementData.title2Value10),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),

                    if (controller.title.value == "Pond Selection Criteria")
                      Column(
                        children: [
                          CommonContainer(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                section(text: PondManagementData.title3Value1),
                                section(text: PondManagementData.title3Value2),
                                section(text: PondManagementData.title3Value3),
                                section(text: PondManagementData.title3Value4),
                                section(text: PondManagementData.title3Value5),
                                section(text: PondManagementData.title3Value6),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),

                    if (controller.title.value == "Pond Preparation Guide")
                      Expanded(
                        child: CommonContainer(
                          margin: const EdgeInsets.all(16.0),
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: controller.data.length,
                            itemBuilder: (context, index) {
                              return CommonText(
                                "${controller.data[index]}",
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                maxLines: 10,
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  title({text}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: CommonText(
            "$text",
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xff0370c3),
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  section({text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Expanded(
            child: CommonText(
              "$text",
              fontSize: 16,
              fontWeight: FontWeight.w500,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  section2({text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Expanded(
            child: CommonText(
              "$text",
              fontSize: 18,
              fontWeight: FontWeight.bold,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  subSection({text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Expanded(
            child: CommonText(
              "$text",
              fontSize: 16,
              fontWeight: FontWeight.w500,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
    );
  }

  boxDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xffebffff), Colors.white],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.blueGrey.withValues(alpha: 0.5),
          spreadRadius: 1,
          blurRadius: 1,
          offset: const Offset(.2, .2),
        ),
      ],
    );
  }
}
