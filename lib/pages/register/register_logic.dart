import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openim/pages/login/login_logic.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';

import '../../core/controller/app_controller.dart';

class RegisterLogic extends GetxController {
  final appLogic = Get.find<AppController>();
  final phoneCtrl = TextEditingController();
  final invitationCodeCtrl = TextEditingController();
  final areaCode = "+86".obs;
  final enabled = false.obs;
  final loginController = Get.find<LoginLogic>();
  String? get email => loginController.operateType == LoginType.email ? phoneCtrl.text.trim() : null;
  String? get phone => loginController.operateType == LoginType.phone ? phoneCtrl.text.trim() : null;

  @override
  void onClose() {
    phoneCtrl.dispose();
    invitationCodeCtrl.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    phoneCtrl.addListener(_onChanged);
    invitationCodeCtrl.addListener(_onChanged);
    super.onInit();
  }

  _onChanged() {
    // 邀请码始终为可选，不参与验证逻辑
    if (loginController.operateType == LoginType.phone) {
      enabled.value = phoneCtrl.text.trim().length >= 6 && RegExp(r'^\d+$').hasMatch(phoneCtrl.text.trim());
    } else {
      enabled.value = phoneCtrl.text.trim().isNotEmpty;
    }
  }

  bool get needInvitationCodeRegister =>
      null != appLogic.clientConfigMap['needInvitationCodeRegister'] && appLogic.clientConfigMap['needInvitationCodeRegister'] != '0';

  // 从输入框获取邀请码
  String? get invitationCode => IMUtils.emptyStrToNull(invitationCodeCtrl.text);

  void openCountryCodePicker() async {
    String? code = await IMViews.showCountryCodePicker();
    if (null != code) areaCode.value = code;
  }

  /// [usedFor] 1：注册，2：重置密码
  Future<bool> requestVerificationCode() => Apis.requestVerificationCode(
        areaCode: areaCode.value,
        phoneNumber: phone,
        email: email,
        usedFor: 1,
        invitationCode: invitationCode,
      );

  void next() async {
    // 注释掉原来的手机号校验规则，改为简单的5位数字校验
    // if (loginController.operateType == LoginType.phone && !IMUtils.isMobile(areaCode.value, phoneCtrl.text)) {
    //   IMViews.showToast(StrRes.plsEnterRightPhone);
    //   return;
    // }

    // 新的手机号校验：至少6位数字
    if (loginController.operateType == LoginType.phone) {
      if (phoneCtrl.text.trim().length < 6 || !RegExp(r'^\d+$').hasMatch(phoneCtrl.text.trim())) {
        IMViews.showToast('请输入至少6位数字的手机号');
        return;
      }
    }

    if (loginController.operateType == LoginType.email && !phoneCtrl.text.isEmail) {
      IMViews.showToast(StrRes.plsEnterRightEmail);
      return;
    }
    // 验证码阶段临时关闭（默认验证码 666666），直接进入设置密码页面。
    // 如需恢复验证码流程，恢复下方被注释的代码块，并删除直接跳转设置密码的逻辑。
    // final success = await LoadingView.singleton.wrap(
    //   asyncFunction: () => requestVerificationCode(),
    // );
    // if (success) {
    //   AppNavigator.startVerifyPhone(
    //     areaCode: areaCode.value,
    //     phoneNumber: phone,
    //     email: email,
    //     usedFor: 1,
    //     invitationCode: invitationCode,
    //   );
    // }

    // 直接进入设置密码
    AppNavigator.startSetPassword(
      areaCode: areaCode.value,
      phoneNumber: phone,
      email: email,
      verificationCode: '666666', // 占位验证码
      usedFor: 1,
      invitationCode: invitationCode,
    );
  }
}
