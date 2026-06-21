import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../../repo/auth.dart';
import '../../../response/profile_response.dart';
import '../../../service/local_storage.dart';

class PoultryProfileController extends GetxController {
  final loginTokenStorage = Get.find<LoginTokenStorage>();
  final authRepository = AuthRepository();
  final profileResponse = Rxn<ProfileResponse>();
  var isLoggedIn = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkLogin();
  }

  void checkLogin() {
    final token = loginTokenStorage.getPoultryToken();
    if (token != null && token.isNotEmpty) {
      isLoggedIn.value = token;
      getProfile();
    } else {
      isLoggedIn.value = '';
    }
  }

  void getProfile() async {
    var response = await authRepository.getProfile(isPoultryFlow: true);
    response.fold(
      (l) => debugPrint("Poultry Profile error: ${l.message}"),
      (r) => profileResponse.value = r,
    );
  }
}
