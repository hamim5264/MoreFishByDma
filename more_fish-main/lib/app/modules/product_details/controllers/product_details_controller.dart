import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../repo/products.dart';

import '../../../response/product_details_response.dart';

class ProductDetailsController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    getDetails();
  }

  ProductsRepository productsRepository = ProductsRepository();
  final productDetailsResponse = Rxn<ProductDetailsResponse>();

  getDetails() async {
    var id = Get.arguments["id"];
    var response = await productsRepository.getProductDetails(id: id);

    response.fold(
      (l) {
        debugPrint('Failed to fetch details: ${l.message}');
      },
      (r) {
        productDetailsResponse.value = r;
        debugPrint("=================================");
        debugPrint(productDetailsResponse.value.toString());
        debugPrint("=================================");
      },
    );
  }
}
