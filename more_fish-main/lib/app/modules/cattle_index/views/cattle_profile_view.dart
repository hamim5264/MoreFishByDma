import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:more_fish/app/service/fcm_service.dart';
import '../../../common_widgets/common_container.dart';
import '../../../common_widgets/common_text.dart';
import '../../../routes/app_pages.dart';
import '../controllers/cattle_index_controller.dart';
import '../controllers/cattle_profile_controller.dart';
import '../controllers/cattle_header_controller.dart';
import '../controllers/cattle_live_monitoring_controller.dart';

class CattleProfileView extends GetView<CattleIndexController> {
  const CattleProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final cattleProfileController = Get.find<CattleProfileController>();
    cattleProfileController.checkLogin();

    return Scaffold(
      backgroundColor: const Color(0xffebffff),
      body: Obx(() {
        var data = cattleProfileController.profileResponse.value;
        return cattleProfileController.isLoggedIn.isEmpty
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
                                border: Border.all(color: Colors.blue.shade100),
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
                            child: const CommonContainer(
                              height: 50,
                              margin: EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 16,
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Change Password",
                                    style: TextStyle(
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
                              await FcmService.clearFcmTokenOnLogout(
                                isCattleFlow: true,
                              );
                              await cattleProfileController.loginTokenStorage
                                  .clearCattleSession();
                              cattleProfileController
                                      .loginTokenStorage
                                      .isCattleLoggedIn
                                      .value =
                                  false;
                              cattleProfileController.isLoggedIn.value = '';

                              if (Get.isRegistered<CattleHeaderController>()) {
                                Get.delete<CattleHeaderController>();
                              }
                              if (Get.isRegistered<
                                CattleLiveMonitoringController
                              >()) {
                                Get.delete<CattleLiveMonitoringController>();
                              }

                              Get.offAllNamed(Routes.DMA_TECHNOLOGIES);
                            },
                            child: CommonContainer(
                              height: 50,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 16,
                              ),
                              alignment: Alignment.center,
                              gradient: const LinearGradient(
                                colors: [Color(0xffffebee), Color(0xffffcdd2)],
                              ),
                              border: Border.all(color: Colors.red.shade100),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Logout",
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
    );
  }
}
