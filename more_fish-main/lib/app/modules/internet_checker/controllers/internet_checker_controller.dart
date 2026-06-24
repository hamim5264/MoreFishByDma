import 'dart:async';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class InternetCheckerController extends GetxController {
  Timer? timer;
  final count = 0.obs;

  checkInternet() async {
    timer?.cancel();
    timer = Timer(const Duration(seconds: 1), () async {
      if (await InternetConnectionChecker.instance.hasConnection) {
        Get.back();
      } else {
        checkInternet();
      }
    });
  }

  void increment() => count.value++;
}
