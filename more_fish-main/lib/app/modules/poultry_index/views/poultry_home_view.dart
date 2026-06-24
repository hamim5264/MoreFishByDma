import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../common_widgets/common_app_bar.dart';
import '../controllers/poultry_index_controller.dart';
import '../controllers/poultry_header_controller.dart';
import 'poultry_live_monitoring_view.dart';
import '../../../routes/app_pages.dart';

class PoultryHomeView extends GetView<PoultryIndexController> {
  const PoultryHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final header = Get.find<PoultryHeaderController>();

    void openIfLoggedIn(VoidCallback navigate) async {
      final canOpen = await controller.ensureLoggedIn();
      if (canOpen) {
        navigate();
      }
    }

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
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.85,
                    children: [
                      _HomeFeatureTile(
                        title: 'live_data_monitoring'.tr,
                        iconAssetPath: 'assets/icons/water_quality_check.png',
                        onTap: () => openIfLoggedIn(
                          () => Get.to(() => const PoultryLiveMonitoringView()),
                        ),
                      ),
                      _HomeFeatureTile(
                        title: 'farm_management'.tr,
                        iconAssetPath:
                            'assets/icons/farm_management/farm_management.png',
                        onTap: () => openIfLoggedIn(
                          () => Get.toNamed(
                            Routes.COMING_SOON,
                            arguments: {'title': 'farm_management'.tr},
                          ),
                        ),
                      ),
                      _HomeFeatureTile(
                        title: 'feed_management'.tr,
                        iconAssetPath:
                            'assets/icons/farm_management/feed_management.png',
                        onTap: () => openIfLoggedIn(
                          () => Get.toNamed(
                            Routes.COMING_SOON,
                            arguments: {'title': 'feed_management'.tr},
                          ),
                        ),
                      ),
                      _HomeFeatureTile(
                        title: 'poultry_disease_treatment'.tr,
                        iconAssetPath:
                            'assets/icons/farm_management/poultry_disease_treatment.png',
                        onTap: () => openIfLoggedIn(
                          () => Get.toNamed(
                            Routes.COMING_SOON,
                            arguments: {
                              'title': 'poultry_disease_treatment'.tr,
                            },
                          ),
                        ),
                      ),
                      _HomeFeatureTile(
                        title: 'chicks_marketplace'.tr,
                        iconAssetPath:
                            'assets/icons/farm_management/chicks_marketplace.png',
                        onTap: () => openIfLoggedIn(
                          () => Get.toNamed(
                            Routes.COMING_SOON,
                            arguments: {'title': 'chicks_marketplace'.tr},
                          ),
                        ),
                      ),
                      _HomeFeatureTile(
                        title: 'poultry_feed_marketplace'.tr,
                        iconAssetPath:
                            'assets/icons/farm_management/poultry_feed_marketplace.png',
                        onTap: () => openIfLoggedIn(
                          () => Get.toNamed(
                            Routes.COMING_SOON,
                            arguments: {'title': 'poultry_feed_marketplace'.tr},
                          ),
                        ),
                      ),
                      _HomeFeatureTile(
                        title: 'auto_feeder'.tr,
                        iconAssetPath:
                            'assets/icons/farm_management/auto_feeder.png',
                        onTap: () => openIfLoggedIn(
                          () => Get.toNamed(
                            Routes.COMING_SOON,
                            arguments: {'title': 'auto_feeder'.tr},
                          ),
                        ),
                      ),
                      _HomeFeatureTile(
                        title: 'weather_forecast'.tr,
                        iconAssetPath:
                            'assets/icons/farm_management/weather_forecast.png',
                        onTap: () => openIfLoggedIn(
                          () => Get.toNamed(
                            Routes.COMING_SOON,
                            arguments: {'title': 'weather_forecast'.tr},
                          ),
                        ),
                      ),
                      _HomeFeatureTile(
                        title: 'live_consultancy'.tr,
                        iconAssetPath:
                            'assets/icons/farm_management/live_consultancy.png',
                        onTap: () => openIfLoggedIn(
                          () => Get.toNamed(
                            Routes.COMING_SOON,
                            arguments: {'title': 'live_consultancy'.tr},
                          ),
                        ),
                      ),
                      _HomeFeatureTile(
                        title: 'auto_water_system'.tr,
                        iconAssetPath:
                            'assets/icons/farm_management/auto_water_system.png',
                        onTap: () => openIfLoggedIn(
                          () => Get.toNamed(
                            Routes.COMING_SOON,
                            arguments: {'title': 'auto_water_system'.tr},
                          ),
                        ),
                      ),
                      _HomeFeatureTile(
                        title: 'financial_management'.tr,
                        iconAssetPath:
                            'assets/icons/farm_management/financial_management.png',
                        onTap: () => openIfLoggedIn(
                          () => Get.toNamed(
                            Routes.COMING_SOON,
                            arguments: {'title': 'financial_management'.tr},
                          ),
                        ),
                      ),
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
}

class _HomeFeatureTile extends StatelessWidget {
  const _HomeFeatureTile({
    required this.title,
    required this.iconAssetPath,
    required this.onTap,
  });

  final String title;
  final String iconAssetPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 233, 234, 205),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(iconAssetPath, height: 40, fit: BoxFit.contain),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
