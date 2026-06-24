import 'package:get/get.dart';

import '../../home/controllers/home_controller.dart';
import '../../more/controllers/more_controller.dart';
import '../../notifications/controllers/notifications_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/index_controller.dart';
import '../../cattle_index/controllers/cattle_header_controller.dart';

class IndexBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CattleHeaderController>(() => CattleHeaderController());
    Get.lazyPut<IndexController>(() => IndexController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<NotificationsController>(() => NotificationsController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<MoreController>(() => MoreController());
  }
}
