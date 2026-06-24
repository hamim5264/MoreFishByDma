import 'package:get/get.dart';
import '../controllers/cattle_index_controller.dart';
import '../controllers/cattle_header_controller.dart';
import '../controllers/cattle_profile_controller.dart';
import '../controllers/cattle_live_monitoring_controller.dart';
import '../controllers/cattle_notifications_controller.dart';

class CattleIndexBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CattleIndexController>(() => CattleIndexController());
    Get.put(CattleHeaderController(), permanent: true);
    Get.lazyPut<CattleProfileController>(() => CattleProfileController());
    Get.lazyPut<CattleNotificationsController>(
      () => CattleNotificationsController(),
    );
    Get.put(CattleLiveMonitoringController(), permanent: true);
  }
}
