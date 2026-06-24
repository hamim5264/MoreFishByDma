import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:more_fish/app/service/fcm_service.dart';
import '../../../common_widgets/common_app_bar.dart';
import '../../../common_widgets/common_container.dart';
import '../../../common_widgets/common_text.dart';
import '../../../routes/app_pages.dart';
import '../../../service/local_storage.dart';
import '../controllers/poultry_header_controller.dart';
import '../controllers/poultry_index_controller.dart';
import '../controllers/poultry_profile_controller.dart';

class PoultryProfileView extends StatelessWidget {
  const PoultryProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final header = Get.find<PoultryHeaderController>();
    final poultryIndexController = Get.find<PoultryIndexController>();
    final poultryProfileController = Get.put(PoultryProfileController());
    poultryProfileController.checkLogin();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xffdbcc68),
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
                  title: 'poultry_care'.tr,
                  cityName: 'dhaka'.tr,
                  date: header.formattedDate.value,
                  time: header.formattedTime.value,
                  temp: header.tempText.value,
                  humidity: header.humidityText.value,
                  logoAssetPath: 'assets/icons/dma_poultry_pulse.png',
                  backgroundColor: const Color(0xffdbcc68),
                ),
              ),

              Expanded(
                child: Obx(() {
                  var data = poultryProfileController.profileResponse.value;
                  return poultryIndexController.isLoggedIn.isEmpty
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
                                        final loginTokenStorage =
                                            Get.find<LoginTokenStorage>();

                                        await FcmService.clearFcmTokenOnLogout(
                                          isPoultryFlow: true,
                                        );

                                        await loginTokenStorage
                                            .removePoultryToken();
                                        await loginTokenStorage
                                            .removePoultryUserId();

                                        poultryIndexController
                                                .isLoggedIn
                                                .value =
                                            '';

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
