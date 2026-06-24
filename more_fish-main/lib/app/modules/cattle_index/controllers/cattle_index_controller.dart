import 'package:get/get.dart';
import '../../../service/local_storage.dart';

class CattleIndexController extends GetxController {
  final selectedIndex = 0.obs;
  var isLoggedIn = ''.obs;

  var listItemsEnglish1 = [
    'live_data_monitoring',
    'farm_management',
    'feed_management',
    'cattle_disease_treatment',
    'cattle_marketplace',
    'cattle_feed_marketplace',
    'auto_feeder',
    'weather_forecast',
    'live_consultancy',
    'auto_water_system',
    'financial_management',
  ].obs;

  var iconList1 = [
    "assets/icons/water_quality_check.png",
    "assets/icons/farm_management/cow.png",
    "assets/icons/farm_management/cow_feed.png",
    "assets/icons/feed_management.png",
    "assets/icons/farm_management/cow.png",
    "assets/icons/doctor_service.png",
    "assets/icons/fish_farm_materials.png",
    "assets/icons/farm_management/cow.png",
    "assets/icons/farm_management/cow.png",
    "assets/icons/fish_medicine.png",
    "assets/icons/feed_management.png",
  ].obs;

  @override
  void onInit() {
    super.onInit();
    checkLogin();
  }

  void checkLogin() {
    final loginTokenStorage = Get.find<LoginTokenStorage>();
    if (loginTokenStorage.hasValidCattleToken()) {
      isLoggedIn.value = loginTokenStorage.getCattleToken()!;
    } else {
      isLoggedIn.value = '';
    }
  }
}
