import 'package:get/get.dart';

import 'create_circle_logic.dart';

class CreateCircleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CreateCircleLogic());
  }
}

