import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_common/src/models/circle.dart';
import 'package:openim_working_circle/src/w_apis.dart';
import 'package:uuid/uuid.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class CreateCircleLogic extends GetxController {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final inviteCodeNumCtrl = TextEditingController();
  final cover = Rxn<AssetEntity>();
  final circleType = 0.obs; // 0 私密圈 1 公开圈（示例）
  final existingAvatar = ''.obs;
  final canInvite = false.obs;
  final inviteCodeNum = 0.obs; // 用于响应式更新UI

  CircleInfo? initialInfo;
  bool get isEdit => initialInfo != null;

  @override
  void onClose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    inviteCodeNumCtrl.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      initialInfo = args['circleInfo'] as CircleInfo?;
    } else if (args is CircleInfo) {
      initialInfo = args;
    }
    if (initialInfo != null) {
      nameCtrl.text = initialInfo!.circleName ?? '';
      descCtrl.text = initialInfo!.description ?? '';
      circleType.value = initialInfo!.visibility ?? circleType.value;
      existingAvatar.value = initialInfo!.avatar ?? initialInfo!.coverUrl ?? '';
      canInvite.value = initialInfo!.canInvite ?? false;
      final num = initialInfo!.inviteCodeNum ?? 0;
      inviteCodeNumCtrl.text = num.toString();
      inviteCodeNum.value = num;
    } else {
      // 新建时初始化为0
      inviteCodeNumCtrl.text = '0';
      inviteCodeNum.value = 0;
    }
    // 监听文本控制器变化
    inviteCodeNumCtrl.addListener(() {
      final value = int.tryParse(inviteCodeNumCtrl.text.trim()) ?? 0;
      inviteCodeNum.value = value;
    });
  }

  Future<void> pickCover() async {
    final assets = await AssetPicker.pickAssets(
      Get.context!,
      pickerConfig: const AssetPickerConfig(maxAssets: 1, requestType: RequestType.image),
    );
    if (assets != null && assets.isNotEmpty) {
      cover.value = assets.first;
      existingAvatar.value = '';
    }
  }

  Future<void> submit() async {
    final name = nameCtrl.text.trim();
    if (name.length < 4 || name.length > 10) {
      IMViews.showToast('圈子名称需4-10个字符');
      return;
    }
    final desc = descCtrl.text.trim();
    if (!isEdit && cover.value == null && existingAvatar.value.isEmpty) {
      IMViews.showToast('请上传圈子封面');
      return;
    }
    String? avatarUrl = existingAvatar.value.isNotEmpty ? existingAvatar.value : null;
    if (cover.value != null) {
      final file = await cover.value!.file;
      if (file == null) {
        IMViews.showToast('封面获取失败，请重试');
        return;
      }
      final compressed = await IMUtils.compressImageAndGetFile(file);
      final target = compressed ?? file;
      final suffix = IMUtils.getSuffix(target.path);
      final uploadRes = await OpenIM.iMManager.uploadFile(
        id: const Uuid().v4(),
        filePath: target.path,
        fileName: "${const Uuid().v4()}$suffix",
      );
      avatarUrl = jsonDecode(uploadRes)['url'];
    }
    if (isEdit) {
      final id = initialInfo?.circleID;
      if (id == null || id.isEmpty) {
        IMViews.showToast('圈子信息异常，无法编辑');
        return;
      }
      final inviteCodeNumStr = inviteCodeNumCtrl.text.trim();
      final inviteCodeNum = int.tryParse(inviteCodeNumStr) ?? 0;
      if (inviteCodeNumStr.isNotEmpty && (inviteCodeNum < 0 || inviteCodeNum > 10)) {
        IMViews.showToast('邀请码数量必须在0-10之间');
        return;
      }
      await LoadingView.singleton.wrap(asyncFunction: () async {
        await WApis.updateCircle(
          circleID: id,
          circleName: name,
          description: desc,
          avatar: avatarUrl,
          visibility: circleType.value,
          canInvite: canInvite.value,
          inviteCodeNum: inviteCodeNum,
        );
      });
      IMViews.showToast('保存成功');
      Get.back(result: true);
      return;
    } else {
    final inviteCodeNumStr = inviteCodeNumCtrl.text.trim();
    final inviteCodeNum = int.tryParse(inviteCodeNumStr) ?? 0;
    if (inviteCodeNumStr.isNotEmpty && (inviteCodeNum < 0 || inviteCodeNum > 10)) {
      IMViews.showToast('邀请码数量必须在0-10之间');
      return;
    }
    await LoadingView.singleton.wrap(asyncFunction: () async {
      await WApis.createCircle(
        circleName: name,
        description: desc,
        avatar: avatarUrl ?? '',
        isPrivate: circleType.value == 0,
        canInvite: canInvite.value,
        inviteCodeNum: inviteCodeNum,
      );
    });
    IMViews.showToast('创建成功');
    Get.back(result: true);
    }
  }

  void switchType(int value) => circleType.value = value;

  void increaseInviteCodeNum() {
    final current = inviteCodeNum.value;
    if (current < 10) {
      final newValue = current + 1;
      inviteCodeNumCtrl.text = newValue.toString();
      inviteCodeNum.value = newValue;
    }
  }

  void decreaseInviteCodeNum() {
    final current = inviteCodeNum.value;
    if (current > 0) {
      final newValue = current - 1;
      inviteCodeNumCtrl.text = newValue.toString();
      inviteCodeNum.value = newValue;
    }
  }
}

