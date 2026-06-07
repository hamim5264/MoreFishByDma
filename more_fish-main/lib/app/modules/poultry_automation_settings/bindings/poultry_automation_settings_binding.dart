import 'package:get/get.dart';
import '../controllers/poultry_automation_settings_controller.dart';

class PoultryAutomationSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PoultryAutomationSettingsController>(
      () => PoultryAutomationSettingsController(),
    );
  }
}
