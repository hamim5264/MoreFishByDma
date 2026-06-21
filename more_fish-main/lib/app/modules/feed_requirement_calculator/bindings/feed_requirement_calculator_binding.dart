import 'package:get/get.dart';

import '../controllers/feed_requirement_calculator_controller.dart';

class FeedRequirementCalculatorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeedRequirementCalculatorController>(
      () => FeedRequirementCalculatorController(),
    );
  }
}
