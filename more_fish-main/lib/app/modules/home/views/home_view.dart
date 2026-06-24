import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common_widgets/common_alert_dialog.dart';
import '../../../common_widgets/common_app_bar.dart';
import '../../../common_widgets/common_container.dart';
import '../../../res/colors/colors.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xffd4fcfd),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.backGround,
          body: Column(
            children: [
              Obx(() {
                final weather = controller.weatherData;
                final main = (weather.isNotEmpty) ? weather['main'] : null;
                final temp = main != null ? (main['temp'] ?? '--') : '--';
                final humidity = main != null
                    ? (main['humidity'] ?? '--')
                    : '--';

                return CommonAppBar(
                  title: 'title'.tr,
                  cityName: "dhaka".tr,
                  date: controller.formattedDate.value,
                  time: controller.formattedTime.value,
                  temp: '$temp°C',
                  humidity: '$humidity%',
                );
              }),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      gridViewSection1(controller),
                      const SizedBox(height: 10),
                      liveConsultancyBanner(controller),
                      const SizedBox(height: 10),
                      promoCard(controller),
                      const SizedBox(height: 10),
                      gridViewSection2(controller),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  liveConsultancyBanner(homeController) => InkWell(
    onTap: () async {
      final Uri launchUri = Uri(scheme: 'tel', path: "+880 1898-938355");
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      }
    },
    child: CommonContainer(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      gradient: const LinearGradient(
        colors: [Color(0xffe0f2f1), Color(0xffffffff)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Row(
        children: [
          Image.asset('assets/icons/doctor.png', height: 60, width: 60),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'live_consultancy'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff004d40),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'consult_with_experts'.tr,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          Image.asset('assets/icons/live-chat.png', height: 40, width: 40),
        ],
      ),
    ),
  );

  promoCard(homeController) => CommonContainer(
    margin: const EdgeInsets.symmetric(horizontal: 12),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    gradient: const LinearGradient(
      colors: [Color(0xffd4fcfd), Color(0xffffffff)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    child: Column(
      children: [
        const Text(
          "পুকুরের পানির অক্সিজেন, পিএইচ, অ্যামোনিয়া, তাপমাত্রা, লবণাক্ততা ও টিডিএস ২৪ ঘণ্টা আপনার মোবাইল অ্যাপে দেখুন!",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xff1a1a1a),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          "(ডিভাইস মূল্য জানার জন্য কল করুন)",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  banner(homeController) => Obx(() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: PageView.builder(
        itemCount: homeController.bannerList.length,
        controller: homeController.pageController,
        onPageChanged: (index) {
          homeController.currentPage.value = index;
        },
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                homeController.bannerList[index],
                fit: BoxFit.fill,
              ),
            ),
          );
        },
      ),
    );
  });

  gridViewSection1(homeController) {
    return Obx(() {
      return GridView.builder(
        padding: const EdgeInsets.all(12.0),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: homeController.listItemsEnglish1.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (context, index) {
          final itemKey = homeController.listItemsEnglish1[index];
          return InkWell(
            onTap: () async {
              if (itemKey == 'live_data_monitoring') {
                controller.checkLogin();
                if (controller.isLoggedIn.value.isEmpty) {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) => PopScope(
                      canPop: false,
                      child: CommonAlertDialog(
                        notNow: () => Get.back(),
                        login: () => Get.toNamed(Routes.LOGIN),
                      ),
                    ),
                  );
                } else {
                  Get.toNamed(Routes.WATER_QUALITY_DEVICE);
                }
              } else if (itemKey == 'fish_disease_detector') {
                Get.toNamed(Routes.FISH_DISEASE_DETECTOR);
              } else if (itemKey == 'pond_management') {
                Get.toNamed(Routes.POND_MANAGEMENT);
              } else if (itemKey == 'feed_management') {
                Get.toNamed(Routes.FEED_MANAGEMENT);
              } else if (itemKey == 'fish_disease_treatment') {
                Get.toNamed(Routes.FISH_DISEASE_TREATMENT);
              } else if (itemKey == 'fish_farm_marketplace') {
                var category = homeController.categoryResponse.value?.data;
                for (int i = 0; i < category.length; i++) {
                  if (category[i].categoryName == "Fish Farming Equipment") {
                    Get.toNamed(
                      Routes.PRODUCT_COMPANIES,
                      arguments: {"id": category[i].guid},
                    );
                  }
                }
              } else if (itemKey == 'fingerlings_marketplace') {
                Get.toNamed(
                  Routes.PRODUCT_COMPANIES,
                  arguments: {"id": "ce86362d-828c-4c81-a644-72d6c27c7e13"},
                );
              } else if (itemKey == 'grown_fish_sell') {
                Get.toNamed(
                  Routes.PRODUCT_COMPANIES,
                  arguments: {"id": "08a69b99-9d57-4097-afc0-b38f49f5318d"},
                );
              } else if (itemKey == 'fish_medicine_enzyme') {
                var category = homeController.categoryResponse.value?.data;
                for (int i = 0; i < category.length; i++) {
                  if (category[i].categoryName == "Fish Medicine") {
                    Get.toNamed(
                      Routes.PRODUCT_COMPANIES,
                      arguments: {"id": category[i].guid},
                    );
                  }
                }
              } else if (itemKey == 'fcr_calculator') {
                Get.toNamed(Routes.FCR_CALCULATOR);
              } else if (itemKey == 'feed_requirement_calculator') {
                Get.toNamed(Routes.FEED_REQUIREMENT_CALCULATOR);
              } else if (itemKey == 'nano_bubble_aeration_system') {
                Get.toNamed(Routes.NANO_BUBBLE);
              } else {
                Get.toNamed(Routes.COMING_SOON);
              }
            },
            child: CommonContainer(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    homeController.iconList1[index],
                    height: 40,
                    width: 40,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "$itemKey".tr,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  gridViewSection2(homeController) => Obx(() {
    return GridView.builder(
      padding: const EdgeInsets.all(12.0),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: homeController.listItemsEnglish2.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final itemKey = homeController.listItemsEnglish2[index];
        return InkWell(
          onTap: () async {
            if (itemKey == "fish_feed_marketplace") {
              var category = homeController.categoryResponse.value?.data;
              for (int i = 0; i < category.length; i++) {
                if (category[i].categoryName == "Fish Feed") {
                  Get.toNamed(
                    Routes.PRODUCT_COMPANIES,
                    arguments: {"id": category[i].guid},
                  );
                }
              }
            } else if (itemKey == "training_workshop") {
              Get.toNamed(Routes.TRAINING_AND_WORKSHOP);
            } else if (itemKey == "farm_management") {
              Get.toNamed(Routes.FARM_MANAGEMENT);
            } else if (itemKey == "auto_aerator_connection") {
              Get.toNamed(Routes.AERATOR_CONNECTION);
            } else if (itemKey == "auto_feeder_connection") {
              Get.toNamed(Routes.FEEDER_CONNECTION);
            } else if (itemKey == "weather_forecast") {
              Get.toNamed(Routes.WEATHER_FORECAST);
            } else if (itemKey == "smart_khamari") {
              Get.toNamed(Routes.SMART_KHAMARI);
            } else if (itemKey == "emergency_service") {
              final Uri launchUri = Uri(
                scheme: 'tel',
                path: "+880 1898-938354",
              );
              if (await canLaunchUrl(launchUri)) {
                await launchUrl(launchUri);
              }
            } else {
              Get.toNamed(Routes.COMING_SOON);
            }
          },
          child: CommonContainer(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  homeController.iconList2[index],
                  height: 40,
                  width: 40,
                ),
                const SizedBox(height: 3),
                Text(
                  "$itemKey".tr,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
        );
      },
    );
  });
}
