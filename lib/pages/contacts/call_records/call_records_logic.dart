import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

class CallRecordsLogic extends GetxController {
  final cacheLogic = Get.find<CacheController>();
  final meetingInfoList = <MeetingInfo>[].obs;
  final nicknameMapping = <String, String>{}.obs;
  final index = 0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<bool> remove(CallRecords records) async {
    await cacheLogic.deleteCallRecords(records);
    return true;
  }

  void switchTab(index) {
    this.index.value = index;
  }
}
