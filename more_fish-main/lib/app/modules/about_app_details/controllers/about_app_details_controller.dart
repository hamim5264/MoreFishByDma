import 'package:get/get.dart';

class AboutAppDetailsController extends GetxController {
  final count = 0.obs;
  var data = '';
  var title = '';

  @override
  void onInit() {
    super.onInit();
    data = Get.arguments["data"];
    title = Get.arguments["title"];
  }

  void increment() => count.value++;
}
