import 'package:get/get.dart';

import 'circle_detail_logic.dart';

class CircleDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CircleDetailLogic());
  }
}

