import 'package:get/get.dart';

import '../controllers/dma_technologies_controller.dart';
import '../../cattle_index/controllers/cattle_header_controller.dart';
import '../../cattle_index/controllers/cattle_live_monitoring_controller.dart';
import '../../../service/local_storage.dart';

class DmaTechnologiesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DmaTechnologiesController>(() => DmaTechnologiesController());

    final storage = Get.find<LoginTokenStorage>();
    if (storage.hasValidCattleToken()) {
      Get.put(CattleHeaderController());
      Get.put(CattleLiveMonitoringController());
    }
  }
}
