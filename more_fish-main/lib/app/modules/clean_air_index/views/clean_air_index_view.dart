import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:more_fish/app/service/local_storage.dart';

import '../../../common_widgets/common_alert_dialog.dart';
import '../../../routes/app_pages.dart';
import '../controllers/clean_air_index_controller.dart';
import 'clean_air_home_view.dart';
import 'clean_air_more_view.dart';
import 'clean_air_notifications_view.dart';
import 'clean_air_profile_view.dart';

class CleanAirIndexView extends GetView<CleanAirIndexController> {
  const CleanAirIndexView({super.key});

  @override
  Widget build(BuildContext context) {
    const pages = [
      CleanAirHomeView(),
      CleanAirNotificationsView(),
      CleanAirProfileView(),
      CleanAirMoreView(),
    ];

    return Obx(() {
      return Scaffold(
        body: pages[controller.selectedIndex.value],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xffebffff),
          currentIndex: controller.selectedIndex.value,
          onTap: (index) {
            if ((index == 1 || index == 2) &&
                controller.isLoggedIn.value.isEmpty) {
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
                      Get.toNamed(Routes.PHARMA_LOGIN);
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
          unselectedItemColor: Colors.blueGrey,
          elevation: 4,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
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
              label: 'Notifications',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: 'More',
            ),
          ],
        ),
      );
    });
  }
}
