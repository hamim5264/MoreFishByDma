import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../common_widgets/common_app_bar.dart';
import '../../../common_widgets/common_container.dart';
import '../../../common_widgets/common_text.dart';
import '../../../res/colors/colors.dart';
import '../../../routes/app_pages.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/more_controller.dart';

class MoreView extends GetView<MoreController> {
  const MoreView({super.key});
  @override
  Widget build(BuildContext context) {

    HomeController homeController = Get.put(HomeController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Color(0xffd4fcfd),
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.dark,
        ),
        child:SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backGround,
          body: Column(
            children: [
              Obx(() {
                final weather = homeController.weatherData;
                final main = (weather != null && weather.isNotEmpty)
                    ? weather['main']
                    : null;
                final temp = main != null ? (main['temp'] ?? '--') : '--';
                final humidity = main != null ? (main['humidity'] ?? '--') : '--';

                return CommonAppBar(
                  title: 'title'.tr,
                  cityName: "dhaka".tr,
                  logoAssetPath: 'assets/icons/dma_more_fish.png',
                  backgroundColor: const Color(0xffd4fcfd),
                  date: homeController.formattedDate.value,
                  time: homeController.formattedTime.value,
                  temp: '$temp°C',
                  humidity: '$humidity%',
                );
              }),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  itemCount: controller.items.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => controller.navigateToItem(index),
                      child: CommonContainer(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        margin: const EdgeInsets.only(bottom: 14),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  controller.items[index],
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                                const Icon(Icons.arrow_forward_ios_outlined, size: 16,)
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              CommonText(
                "MoreFish: 2.1.2",
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
              ),
              const SizedBox(height: 30,)
            ],
          ),
      ),
        )
    );
  }
}
