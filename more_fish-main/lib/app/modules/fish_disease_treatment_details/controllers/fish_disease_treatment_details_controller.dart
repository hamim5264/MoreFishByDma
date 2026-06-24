import 'package:get/get.dart';

class FishDiseaseTreatmentDetailsController extends GetxController {
  final count = 0.obs;
  var title = '';
  var data = [];

  @override
  void onInit() {
    super.onInit();
    title = Get.arguments["diseaseName"];
    data = Get.arguments["data"];
  }

  void increment() => count.value++;
}
