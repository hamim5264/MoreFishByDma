import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common_widgets/common_alert_dialog.dart';
import '../../../common_widgets/common_container.dart';
import '../../../routes/app_pages.dart';
import '../controllers/cattle_index_controller.dart';
import 'cattle_live_monitoring_view.dart';

class CattleHomeView extends GetView<CattleIndexController> {
  const CattleHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
      itemCount: controller.listItemsEnglish1.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 14.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () async {
            controller.checkLogin();
            if (controller.isLoggedIn.value.isEmpty) {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => PopScope(
                  canPop: false,
                  child: CommonAlertDialog(
                    notNow: () => Get.back(),
                    login: () async {
                      Get.back();
                      final result = await Get.toNamed(
                        Routes.CATTLE_LOGIN,
                        arguments: {'fromGuard': true},
                      );
                      controller.checkLogin();
                      if (result == true) {
                        if (index == 0) {
                          Get.to(
                            () => const CattleLiveMonitoringView(),
                            routeName: '/cattle-live-monitoring',
                          );
                        } else {
                          Get.toNamed(Routes.COMING_SOON);
                        }
                      }
                    },
                  ),
                ),
              );
            } else {
              if (index == 0) {
                Get.to(
                  () => const CattleLiveMonitoringView(),
                  routeName: '/cattle-live-monitoring',
                );
              } else {
                Get.toNamed(Routes.COMING_SOON);
              }
            }
          },
          child: CommonContainer(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                  width: 50,
                  child: Image.asset(
                    controller.iconList1[index],
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  controller.listItemsEnglish1[index].tr,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
