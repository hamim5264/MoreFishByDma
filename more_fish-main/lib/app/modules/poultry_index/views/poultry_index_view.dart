import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:more_fish/app/service/local_storage.dart';

import '../controllers/poultry_index_controller.dart';
import 'poultry_home_view.dart';
import 'poultry_more_view.dart';
import 'poultry_notifications_view.dart';
import 'poultry_profile_view.dart';

class PoultryIndexView extends GetView<PoultryIndexController> {
  const PoultryIndexView({super.key});

  @override
  Widget build(BuildContext context) {
    const pages = [
      PoultryHomeView(),
      PoultryNotificationsView(),
      PoultryProfileView(),
      PoultryMoreView(),
    ];

    return Obx(() {
      return Scaffold(
        body: pages[controller.selectedIndex.value],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xffebffff),
          currentIndex: controller.selectedIndex.value,
          onTap: (index) async {
            if (index != 0) {
              final canOpen = await controller.ensureLoggedIn();
              if (!canOpen) {
                controller.selectedIndex.value = 0;
                return;
              }
            }

            controller.selectedIndex.value = index;
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xff0370c3),
          unselectedItemColor: Colors.blueGrey,
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
