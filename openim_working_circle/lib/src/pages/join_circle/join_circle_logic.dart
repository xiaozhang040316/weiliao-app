import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_working_circle/src/w_apis.dart';
import 'invite_code_dialog.dart';

class JoinCircleLogic extends GetxController {
  final searchCtrl = TextEditingController();
  final circles = <CircleInfo>[].obs;
  final loading = false.obs;
  
  /// 搜索防抖定时器
  Timer? _searchDebounceTimer;

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    searchCtrl.dispose();
    super.onClose();
  }

  @override
  void onReady() {
    _search();
    super.onReady();
  }

  void onSearchChanged(String _) {
    // 防抖搜索
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _search();
    });
  }

  Future<void> _search() async {
    loading.value = true;
    try {
      final list = await WApis.searchCircle(
        keyword: searchCtrl.text.trim(),
        pageNumber: 1,
        showNumber: 50,
      );
      circles.assignAll(list);
    } finally {
      loading.value = false;
    }
  }

  Future<void> joinCircle(CircleInfo info) async {
    // 如果列表中的圈子信息没有 inviteCodeNum，需要先获取完整的圈子信息
    CircleInfo? fullInfo = info;
    if (info.inviteCodeNum == null) {
      try {
        fullInfo = await WApis.getCircleInfo(circleID: info.circleID ?? '');
      } catch (e) {
        Logger.print('获取圈子信息失败: $e');
        // 如果获取失败，使用列表中的信息继续
      }
    }

    final inviteCodeNum = fullInfo?.inviteCodeNum ?? 0;
    
    // 如果需要邀请码，弹出输入对话框
    if (inviteCodeNum > 0) {
      final inviteCodes = await _showInviteCodeDialog(inviteCodeNum);
      if (inviteCodes == null || inviteCodes.length != inviteCodeNum) {
        // 用户取消或输入不完整
        return;
      }
      // 调用加入接口，传递邀请码
      await LoadingView.singleton.wrap(asyncFunction: () async {
        await WApis.joinCircle(
          circleID: info.circleID ?? '',
          reqMessage: '',
          inviteCodes: inviteCodes,
        );
      });
    } else {
      // 不需要邀请码，直接加入
      await LoadingView.singleton.wrap(asyncFunction: () async {
        await WApis.joinCircle(circleID: info.circleID ?? '', reqMessage: '');
      });
    }
    IMViews.showToast('已加入圈子');
    Get.back(result: true);
  }

  /// 显示输入邀请码的对话框
  Future<List<String>?> _showInviteCodeDialog(int count) async {
    final result = await Get.dialog<List<String>>(
      InviteCodeDialog(
        count: count,
      ),
    );
    return result;
  }
}

