import 'package:get/get.dart';

class PondManagementDetailsController extends GetxController {
  final count = 0.obs;
  var title = ''.obs;
  var data = [].obs;

  @override
  void onInit() {
    super.onInit();
    title.value = Get.arguments["title"];
    data.value = Get.arguments["data"];
  }

  void increment() => count.value++;
}
