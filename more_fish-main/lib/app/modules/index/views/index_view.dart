import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:more_fish/app/common_widgets/common_alert_dialog.dart';
import 'package:more_fish/app/service/local_storage.dart';

import '../../../routes/app_pages.dart';
import '../../home/views/home_view.dart';
import '../../more/views/more_view.dart';
import '../../notifications/views/notifications_view.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/index_controller.dart';

class IndexView extends GetView<IndexController> {
  const IndexView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeView(),
      const NotificationsView(),
      const ProfileView(),
      const MoreView(),
    ];

    return Obx(() {
      return Scaffold(
        body: pages[controller.selectedIndex.value],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xffebffff),
          currentIndex: controller.selectedIndex.value,
          onTap: (index) {
            if ((index == 1 || index == 2) && !controller.isUserLoggedIn) {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => PopScope(
                  canPop: false,
                  child: CommonAlertDialog(
                    notNow: () {
                      Get.back();
                      controller.selectedIndex.value = 0;
                    },
                    login: () {
                      Get.back();
                      Get.toNamed(Routes.LOGIN);
                    },
                  ),
                ),
              );
              return;
            }

            controller.selectedIndex.value = index;
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xff0370c3),
          unselectedItemColor: Colors.blueGrey.shade300,
          elevation: 4,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: 'home'.tr,
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications),
                  Obx(() {
                    final count = Get.find<LoginTokenStorage>()
                        .unreadNotificationCount
                        .value;
                    if (count == 0) return const SizedBox.shrink();
                    return Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }),
                ],
              ),
              label: 'notifications'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: 'profile'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu),
              label: 'more'.tr,
            ),
          ],
        ),
      );
    });
  }
}
