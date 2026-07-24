import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_working_circle/src/w_apis.dart';

class CircleMembersLogic extends GetxController {
  late final String circleID;
  final members = <CircleMember>[].obs;
  final loading = false.obs;

  String get selfUserID => OpenIM.iMManager.userID;

  bool get isOwner => members.any(
        (e) =>
            e.userID == selfUserID &&
            (e.isAdmin || e.userID == selfUserID),
      );

  bool isSelf(CircleMember m) => m.userID == selfUserID;

  @override
  void onInit() {
    circleID = Get.arguments['circleID'];
    super.onInit();
  }

  @override
  void onReady() {
    loadMembers();
    super.onReady();
  }

  Future<void> loadMembers() async {
    loading.value = true;
    try {
      final list = await WApis.getCircleMembers(circleID: circleID, showNumber: 200);
      members.assignAll(list);
    } finally {
      loading.value = false;
    }
  }

  Future<void> banOrUnban(CircleMember m) async {
    if (isSelf(m)) return;
    await LoadingView.singleton.wrap(asyncFunction: () async {
      if (m.isBanned) {
        await WApis.unbanMember(circleID: circleID, targetUserID: m.userID!);
      } else {
        await WApis.banMember(circleID: circleID, targetUserID: m.userID!);
      }
    });
    await loadMembers();
  }
}

