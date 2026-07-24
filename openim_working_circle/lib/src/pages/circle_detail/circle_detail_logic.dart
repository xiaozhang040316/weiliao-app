import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_working_circle/openim_working_circle.dart';
import 'package:openim_working_circle/src/pages/work_moments_list/preview_picture/preview_picture_view.dart';
import 'package:openim_working_circle/src/pages/work_moments_list/preview_video/preview_video_view.dart';
import 'package:openim_working_circle/src/routes/w_navigator.dart';
import 'package:openim_working_circle/src/w_apis.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:uuid/uuid.dart';

class CircleDetailLogic extends GetxController {
  late final String circleID;
  final circleInfo = Rxn<CircleInfo>();
  final members = <CircleMember>[].obs;
  final workMoments = <WorkMoments>[].obs;
  final hasMore = true.obs;
  final pageSize = 20;
  int pageNo = 1;
  final refreshCtrl = RefreshController();
  String get selfID => OpenIM.iMManager.userID;

  NavigatorState? get navigator =>
      Get.context?.findRootAncestorStateOfType<NavigatorState>();

  bool get isOwner => circleInfo.value?.ownerUserID == selfID;

  bool get isAdmin => members.any((e) => e.userID == selfID && e.isAdmin);

  bool get canInviteEnabled =>
      isOwner || isAdmin || circleInfo.value?.canInvite == true;

  /// 检查当前用户是否被封禁
  bool get isSelfBanned {
    try {
      final selfMember = members.firstWhere((e) => e.userID == selfID);
      return selfMember.isBanned;
    } catch (e) {
      // 如果找不到当前用户，默认未封禁
      return false;
    }
  }

  SelectContactsBridge? get contactsBridge => PackageBridge.selectContactsBridge;

  @override
  void onInit() {
    circleID = Get.arguments['circleID'];
    super.onInit();
  }

  @override
  void onReady() {
    loadInfo();
    loadMembers();
    queryList();
    super.onReady();
  }

  Future<void> loadInfo() async {
    try {
      circleInfo.value = await WApis.getCircleInfo(circleID: circleID);
    } catch (e) {
      Logger.print('加载圈子信息失败:$e');
    }
  }

  Future<void> loadMembers() async {
    try {
      final list = await WApis.getCircleMembers(circleID: circleID);
      members.assignAll(list);
    } catch (e) {
      Logger.print('加载圈子成员失败:$e');
    }
  }

  Future<void> queryList() async {
    try {
      final result = await WApis.getCircleMoments(
        circleID: circleID,
        pageNumber: pageNo = 1,
        showNumber: pageSize,
      );
      final list = result.workMoments ?? [];
      hasMore.value = list.isNotEmpty && list.length == pageSize;
      workMoments.assignAll(list);
    } finally {
      refreshCtrl.refreshCompleted();
      hasMore.value ? refreshCtrl.loadComplete() : refreshCtrl.loadNoData();
    }
  }

  Future<void> loadMore() async {
    try {
      final result = await WApis.getCircleMoments(
        circleID: circleID,
        pageNumber: ++pageNo,
        showNumber: pageSize,
      );
      final list = result.workMoments ?? [];
      hasMore.value = list.isNotEmpty && list.length == pageSize;
      workMoments.addAll(list);
    } catch (_) {
      pageNo--;
    }
    hasMore.value ? refreshCtrl.loadComplete() : refreshCtrl.loadNoData();
  }

  Future<void> banOrUnban(CircleMember m) async {
    await LoadingView.singleton.wrap(asyncFunction: () async {
      if (m.isBanned) {
        await WApis.unbanMember(circleID: circleID, targetUserID: m.userID!);
      } else {
        await WApis.banMember(circleID: circleID, targetUserID: m.userID!);
      }
    });
    await loadMembers();
  }

  Future<void> quitCircle() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认退出圈子'),
        content: const Text('退出后需要重新申请加入该圈子，是否继续？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('退出'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await LoadingView.singleton.wrap(
      asyncFunction: () async {
        await WApis.quitCircle(circleID: circleID);
      },
    );
    Get.back(result: true);
  }

  Future<void> deleteCircle() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认解散圈子'),
        content: const Text('解散后圈子及内容将被清除，是否继续？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('解散'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await LoadingView.singleton.wrap(
      asyncFunction: () async {
        await WApis.deleteCircle(circleID: circleID);
      },
    );
    Get.back(result: true);
  }

  Future<void> editCircle() async {
    final info = circleInfo.value;
    if (info == null) return;
    final result = await WNavigator.startCreateCircle(
      circleInfo: info,
      isEdit: true,
    );
    if (result == true) {
    await loadInfo();
    }
  }

  Future<void> inviteMembers() async {
    if (!canInviteEnabled) {
      IMViews.showToast('暂无邀请权限');
      return;
    }
    final selected = await contactsBridge?.selectContacts(
      0,
      ex: 'circleInvite', // 仅好友/最近聊天，不展示群组
    );
    final ids = <String>[];
    void addId(dynamic v) {
      if (v == null) return;
      if (v is String) {
        ids.add(v);
        return;
      }
      if (v is ConversationInfo) {
        if (v.isSingleChat && (v.userID?.isNotEmpty ?? false)) {
          ids.add(v.userID!);
        }
        return;
      }
      if (v is Map) {
        // 跳过群组等非好友条目
        if (v.containsKey('groupID') || v.containsKey('groupId')) return;
        final id = v['userID'] ?? v['userId'];
        if (id is String && id.isNotEmpty) ids.add(id);
        return;
      }
      try {
        final id = (v as dynamic).userID as String?;
        if (id != null && id.isNotEmpty) ids.add(id);
      } catch (_) {}
    }

    if (selected is Map) {
      selected.values.forEach(addId);
    } else if (selected is List) {
      selected.forEach(addId);
    } else {
      addId(selected);
    }

    if (ids.isEmpty) {
      IMViews.showToast('请选择要邀请的好友');
      return;
    }

    await LoadingView.singleton.wrap(
      asyncFunction: () => WApis.inviteMembers(circleID: circleID, targetUserIDs: ids),
    );
    IMViews.showToast('已添加到圈子');
  }

  void previewPicture(int index, List<Metas> metas) {
    navigator?.push(TransparentRoute(
      builder: (BuildContext context) => GestureDetector(
        onTap: () => Get.back(),
        child: PreviewPicturePage(
          metas: metas,
          currentIndex: index,
          heroTag: metas.elementAt(index).original,
        ),
      ),
    ));
  }

  void previewVideo(String url, String? coverUrl) {
    navigator?.push(TransparentRoute(
      builder: (BuildContext context) => PreviewVideoPage(
        heroTag: url,
        url: url,
        coverUrl: coverUrl,
      ),
    ));
  }

  void viewUserProfile(WorkMoments moments) =>
      PackageBridge.viewUserProfileBridge?.viewUserProfile(
        moments.userID!,
        moments.nickname,
        moments.faceURL,
      );

  void viewMembers() => WNavigator.startCircleMembers(circleID: circleID);

  /// 生成邀请码
  Future<void> generateInviteCode() async {
    if (isSelfBanned) {
      IMViews.showToast('您已被封禁，无法生成邀请码');
      return;
    }
    try {
      final inviteCode = await LoadingView.singleton.wrap<String>(
        asyncFunction: () => WApis.generateInviteCode(circleID: circleID),
      );
      // 显示邀请码对话框
      await Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: const Text('邀请码'),
          content: SelectableText(
            inviteCode,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () {
                IMUtils.copy(text: inviteCode);
                IMViews.showToast('已复制');
              },
              child: const Text('复制'),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    } catch (e) {
      Logger.print('生成邀请码失败: $e');
    }
  }

  /// 删除圈子动态
  Future<void> deleteCircleMoment(WorkMoments moments) async {
    await LoadingView.singleton.wrap(
      asyncFunction: () async {
        await WApis.deleteMoments(workMomentID: moments.workMomentID!);
      },
    );
    workMoments.remove(moments);
  }
}

