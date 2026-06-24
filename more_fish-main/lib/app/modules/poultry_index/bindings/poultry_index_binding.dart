import 'package:get/get.dart';
import '../controllers/poultry_index_controller.dart';
import '../controllers/poultry_header_controller.dart';
import '../controllers/poultry_notifications_controller.dart';
import '../../cattle_index/controllers/cattle_header_controller.dart';
import '../controllers/poultry_live_monitoring_controller.dart';

class PoultryIndexBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CattleHeaderController>(() => CattleHeaderController());

    Get.lazyPut<PoultryIndexController>(() => PoultryIndexController());

    Get.lazyPut<PoultryHeaderController>(() => PoultryHeaderController());

    Get.lazyPut<PoultryNotificationsController>(
      () => PoultryNotificationsController(),
    );

    Get.lazyPut<PoultryLiveMonitoringController>(
      () => PoultryLiveMonitoringController(),
      fenix: true,
    );
  }
}
