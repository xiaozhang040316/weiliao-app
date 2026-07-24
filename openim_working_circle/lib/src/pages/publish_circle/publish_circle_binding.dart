import 'package:get/get.dart';

import 'publish_circle_logic.dart';

class PublishCircleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PublishCircleLogic());
  }
}

