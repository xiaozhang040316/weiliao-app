import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_working_circle/src/w_apis.dart';

class MyCirclesLogic extends GetxController {
  final circles = <CircleInfo>[].obs;
  final loading = false.obs;

  @override
  void onReady() {
    _load();
    super.onReady();
  }

  Future<void> _load() async {
    loading.value = true;
    try {
      final list = await WApis.getCircleList(showNumber: 200);
      circles.assignAll(list);
    } finally {
      loading.value = false;
    }
  }
  
  void refresh() => _load();
}

