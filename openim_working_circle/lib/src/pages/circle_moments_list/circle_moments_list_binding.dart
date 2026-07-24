import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'circle_moments_list_logic.dart';

class CircleMomentsListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CircleMomentsListLogic(), tag: GetTags.circleMoments);
  }
}

