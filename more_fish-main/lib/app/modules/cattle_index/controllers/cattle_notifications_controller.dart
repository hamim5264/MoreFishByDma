import 'package:get/get.dart';
import 'package:more_fish/app/service/local_storage.dart';
import '../../../repo/cattle_live_repo.dart';
import '../../../response/cattle_notifications_response.dart';

class CattleNotificationsController extends GetxController {
  final CattleLiveDataRepository _repository = CattleLiveDataRepository();

  final notifications = <NotificationData>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  @override
  void onReady() {
    super.onReady();
    // ✅ Reset unread count when user opens notifications screen
    Get.find<LoginTokenStorage>().unreadNotificationCount.value = 0;
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    error.value = '';
    final result = await _repository.getNotifications();
    result.fold(
      (l) => error.value = l.message,
      (r) => notifications.assignAll(r.data ?? []),
    );
    isLoading.value = false;
  }
}
