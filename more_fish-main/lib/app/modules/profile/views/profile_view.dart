import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:more_fish/app/common_widgets/common_text.dart';
import 'package:more_fish/app/service/fcm_service.dart';
import '../../../common_widgets/common_app_bar.dart';
import '../../../common_widgets/common_container.dart';
import '../../../res/colors/colors.dart';
import '../../../routes/app_pages.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.put(HomeController());
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
                final weather = homeController.weatherData;
                final main = (weather.isNotEmpty) ? weather['main'] : null;
                final temp = main != null ? (main['temp'] ?? '--') : '--';
                final humidity = main != null
                    ? (main['humidity'] ?? '--')
                    : '--';

                final isPharma = controller.activeMode.value == 'pharma';

                return CommonAppBar(
                  title: isPharma ? 'pharma_care'.tr : 'title'.tr,
                  cityName: "dhaka".tr,
                  logoAssetPath: isPharma
                      ? 'assets/icons/dma_pharmaceutical.png'
                      : 'assets/icons/dma_more_fish.png',
                  backgroundColor: isPharma ? const Color(0xffe0f2f1) : null,
                  date: '${homeController.formattedDate}',
                  time: '${homeController.formattedTime}',
                  temp: '$temp°C',
                  humidity: '$humidity%',
                );
              }),
              Expanded(
                child: Obx(() {
                  var data = controller.profileResponse.value;
                  return controller.isLoggedIn.isEmpty
                      ? const SizedBox()
                      : data == null
                      ? const Center(child: Text('No cached profile yet.'))
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              Expanded(
                                child: CommonContainer(
                                  width: double.infinity,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blue.shade50,
                                          border: Border.all(
                                            color: Colors.blue.shade100,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Color(0xff0370c3),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      CommonText(
                                        "${data.data?.firstName ?? ''} ${data.data?.lastName ?? ''} ",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      CommonText(
                                        data.data?.usrEmail ?? '',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.blueGrey,
                                      ),
                                      const SizedBox(height: 8),
                                      if (data.data?.userPhone != null)
                                        CommonText(
                                          "${data.data?.userPhone?.phnCell ?? ''}",
                                          fontWeight: FontWeight.w500,
                                          fontSize: 18,
                                        ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        Get.toNamed(Routes.PASSWORD_CHANGE);
                                      },
                                      child: CommonContainer(
                                        height: 50,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 0,
                                          vertical: 16,
                                        ),
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "change_password".tr,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.justify,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        await FcmService.clearFcmTokenOnLogout();

                                        await controller.loginTokenStorage
                                            .clearMoreFishSession();
                                        await controller.loginTokenStorage
                                            .clearPharmaSession();

                                        controller.isLoggedIn.value = '';
                                        Get.offAllNamed(
                                          Routes.DMA_TECHNOLOGIES,
                                        );
                                      },
                                      child: CommonContainer(
                                        height: 50,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 0,
                                          vertical: 16,
                                        ),
                                        alignment: Alignment.center,
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xffffebee),
                                            Color(0xffffcdd2),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: Colors.red.shade100,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "logout".tr,
                                              style: TextStyle(
                                                color: Colors.red.shade700,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.justify,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
