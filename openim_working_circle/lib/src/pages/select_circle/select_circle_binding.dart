import 'package:get/get.dart';

import 'select_circle_logic.dart';

class SelectCircleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SelectCircleLogic());
  }
}

