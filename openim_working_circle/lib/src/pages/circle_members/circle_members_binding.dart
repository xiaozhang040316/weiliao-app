import 'package:get/get.dart';

import 'circle_members_logic.dart';

class CircleMembersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CircleMembersLogic());
  }
}

