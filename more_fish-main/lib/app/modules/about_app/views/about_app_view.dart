import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:more_fish/app/common_widgets/common_container.dart';
import 'package:more_fish/app/common_widgets/common_text.dart';
import '../../../common_widgets/common_app_bar.dart';
import '../../../res/colors/colors.dart';
import '../../../routes/app_pages.dart';
import '../../home/controllers/home_controller.dart';
import '../../cattle_index/controllers/cattle_header_controller.dart';
import '../controllers/about_app_controller.dart';

class AboutAppView extends GetView<AboutAppController> {
  const AboutAppView({super.key});
  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.put(HomeController());
    final header = Get.find<CattleHeaderController>();

    return Scaffold(
      backgroundColor: AppColors.backGround,
      body: Column(
        children: [
          Obx(() {
            final module = header.activeModule.value;
            
            String title = 'title'.tr;
            String logo = "assets/icons/logo_trade_mark.jpg";
            Color? bgColor;

            switch (module) {
              case 'cattle':
                title = 'Cattle Care';
                logo = 'assets/icons/dma_cattle_care.png';
                bgColor = Colors.white;
                break;
              case 'poultry':
                title = 'Poultry Care';
                logo = 'assets/icons/dma_poultry_pulse.png';
                bgColor = const Color(0xffdbcc68);
                break;
              case 'pharma':
                title = 'Pharma Care';
                logo = 'assets/icons/dma_pharmaceutical.png';
                bgColor = const Color(0xffe0f2f1);
                break;
              case 'more_fish':
              default:
                title = 'More Fish';
                logo = 'assets/icons/dma_more_fish.png';
                bgColor = const Color(0xffd4fcfd);
                break;
            }

            final weather = homeController.weatherData;
            final main = (weather != null && weather.isNotEmpty)
                ? weather['main']
                : null;
            final temp = main != null ? (main['temp'] ?? '--') : '--';
            final humidity = main != null ? (main['humidity'] ?? '--') : '--';

            return CommonAppBar(
              title: title,
              cityName: "dhaka".tr,
              logoAssetPath: logo,
              backgroundColor: bgColor,
              date: homeController.formattedDate.value,
              time: homeController.formattedTime.value,
              temp: '$temp°C',
              humidity: '$humidity%',
            );
          }),
          Expanded(
              child: ListView.builder(
            padding: const EdgeInsets.only(top: 16),
            itemCount: controller.titleList.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Get.toNamed(Routes.ABOUT_APP_DETAILS, arguments: {
                    "title": controller.titleList[index],
                    "data": controller.dataList[index]
                  });
                },
                child: CommonContainer(
                  margin:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 14),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CommonText(
                              controller.titleList[index].tr,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              maxLines: 3,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          )),
        ],
      ),
    );
  }
}
