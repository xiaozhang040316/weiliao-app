import 'package:get/get.dart';

import 'my_circles_logic.dart';

class MyCirclesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MyCirclesLogic());
  }
}

