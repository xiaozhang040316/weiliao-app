import 'package:get/get.dart';

import 'join_circle_logic.dart';

class JoinCircleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => JoinCircleLogic());
  }
}

