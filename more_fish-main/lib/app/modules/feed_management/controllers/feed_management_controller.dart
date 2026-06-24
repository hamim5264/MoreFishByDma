import 'package:get/get.dart';
import 'package:more_fish/app/res/strings/feed_management.dart';

class FeedManagementController extends GetxController {
  var titleList = [
    'types',
    'guidelines',
    'quantity',
    'methods',
    'relationship',
    'feeding_tips',
    'ration',
    'calculator',
  ];

  var dataList = [
    FeedManagementData.data1,
    FeedManagementData.data2,
    FeedManagementData.data3,
    FeedManagementData.data4,
    FeedManagementData.data5,
    FeedManagementData.data6,
    FeedManagementData.data7,
    FeedManagementData.data8,
  ];

  final count = 0.obs;

  void increment() => count.value++;
}
