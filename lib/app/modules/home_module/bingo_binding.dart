import 'package:get/get.dart';
import 'package:flutter_application_1/app/modules/home_module/bingo_controller.dart';

class BingoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BingoController>(() => BingoController());
  }
}
