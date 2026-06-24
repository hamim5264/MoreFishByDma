import 'dart:async';
import 'package:get/get.dart';
import '../../cattle_index/controllers/cattle_header_controller.dart';

class PoultryHeaderController extends GetxController {
  final _master = Get.find<CattleHeaderController>();

  RxString get formattedDate => _master.formattedDate;

  RxString get formattedTime => _master.formattedTime;

  RxString get tempText => _master.tempText;

  RxString get humidityText => _master.humidityText;

  @override
  void onInit() {
    super.onInit();
    _master.refreshWeather();
  }

  Future<void> refreshWeather() async {
    await _master.refreshWeather();
  }
}
