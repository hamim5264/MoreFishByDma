import 'package:get/get.dart';

import '../controllers/cattle_automation_settings_controller.dart';

class CattleAutomationSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CattleAutomationSettingsController>(
      () => CattleAutomationSettingsController(),
    );
  }
}
