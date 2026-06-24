import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../common_widgets/common_app_bar.dart';
import '../../../common_widgets/common_container.dart';
import '../../../common_widgets/common_text.dart';
import '../../../routes/app_pages.dart';
import '../controllers/clean_air_header_controller.dart';
import '../controllers/clean_air_profile_controller.dart';

class CleanAirProfileView extends GetView<CleanAirProfileController> {
  const CleanAirProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final header = Get.find<CleanAirHeaderController>();
    controller.checkLogin();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xffd4fcfd),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xffebffff),
          body: Column(
            children: [
              Obx(
                () => CommonAppBar(
                  title: 'pharma_care'.tr,
                  cityName: 'dhaka'.tr,
                  date: header.formattedDate.value,
                  time: header.formattedTime.value,
                  temp: header.tempText.value,
                  humidity: header.humidityText.value,
                  logoAssetPath: 'assets/icons/dma_pharmaceutical.png',
                  backgroundColor: const Color(0xff3B73A5),
                ),
              ),
              Expanded(
                child: Obx(() {
                  final data = controller.profileResponse.value;
                  return controller.isLoggedIn.value.isEmpty
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
                                        "${data.data?.firstName ?? ''} ${data.data?.lastName ?? ''}",
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
                                        await controller.logout();
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
                                              'logout'.tr,
                                              style: TextStyle(
                                                color: Colors.red.shade700,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
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
