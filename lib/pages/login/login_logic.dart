import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/pages/mine/server_config/server_config_binding.dart';
import 'package:openim/pages/mine/server_config/server_config_view.dart';
import 'package:openim_common/openim_common.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/controller/im_controller.dart';
import '../../core/controller/push_controller.dart';
import '../../routes/app_navigator.dart';

enum LoginType {
  phone,
  email,
}

extension LoginTypeExt on LoginType {
  int get rawValue {
    switch (this) {
      case LoginType.phone:
        return 0;
      case LoginType.email:
        return 1;
    }
  }

  String get name {
    switch (this) {
      case LoginType.phone:
        return StrRes.phoneNumber;
      case LoginType.email:
        return StrRes.email;
    }
  }

  String get hintText {
    switch (this) {
      case LoginType.phone:
        return StrRes.plsEnterPhoneNumber;
      case LoginType.email:
        return StrRes.plsEnterEmail;
    }
  }

  String get exclusiveName {
    switch (this) {
      case LoginType.phone:
        return StrRes.email;
      case LoginType.email:
        return StrRes.phoneNumber;
    }
  }
}

class LoginLogic extends GetxController {
  final imLogic = Get.find<IMController>();
  final pushLogic = Get.find<PushController>();
  final phoneCtrl = TextEditingController();
  final pwdCtrl = TextEditingController();
  final verificationCodeCtrl = TextEditingController();
  final obscureText = true.obs;
  final enabled = false.obs;
  final areaCode = "+86".obs;
  final isPasswordLogin = true.obs;
  final versionInfo = ''.obs;
  final loginType = LoginType.phone.obs;
  String? get email => loginType.value == LoginType.email ? phoneCtrl.text.trim() : null;
  String? get phone => loginType.value == LoginType.phone ? phoneCtrl.text.trim() : null;
  LoginType operateType = LoginType.phone;

  _initData() async {
    var map = DataSp.getLoginAccount();
    if (map is Map) {
      String? phoneNumber = map["phoneNumber"];
      String? areaCode = map["areaCode"];
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        phoneCtrl.text = phoneNumber;
      }
      if (areaCode != null && areaCode.isNotEmpty) {
        this.areaCode.value = areaCode;
      }
    }

    loginType.value = (await DataSp.getLoginType()) == 0 ? LoginType.phone : LoginType.email;
  }

  @override
  void onClose() {
    phoneCtrl.dispose();
    pwdCtrl.dispose();
    verificationCodeCtrl.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    _initData();
    phoneCtrl.addListener(_onChanged);
    pwdCtrl.addListener(_onChanged);
    verificationCodeCtrl.addListener(_onChanged);
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    getPackageInfo();
  }

  _onChanged() {
    // 仅密码登录：账号与密码同时非空才可登录
    enabled.value = phoneCtrl.text.trim().isNotEmpty && pwdCtrl.text.trim().isNotEmpty;
  }

  login() {
    DataSp.putLoginType(loginType.value.rawValue);
    LoadingView.singleton.wrap(asyncFunction: () async {
      var suc = await _login();
      if (suc) {
        Get.find<CacheController>().resetCache();
        AppNavigator.startMain();
      }
    });
  }

  Future<bool> _login() async {
    try {
      // 修改手机号校验规则：至少6个字符即可
      if (phone?.isNotEmpty == true && phoneCtrl.text.trim().length < 6) {
        IMViews.showToast('手机号必须至少6个字符');
        return false;
      }

      if (email?.isNotEmpty == true && !phoneCtrl.text.isEmail) {
        IMViews.showToast(StrRes.plsEnterRightEmail);
        return false;
      }
      final password = IMUtils.emptyStrToNull(pwdCtrl.text);
      final code = IMUtils.emptyStrToNull(verificationCodeCtrl.text);
      final data = await Apis.login(
        areaCode: areaCode.value,
        phoneNumber: phone,
        email: email,
        password: password,
        verificationCode: null,
      );
      final account = {"areaCode": areaCode.value, "phoneNumber": phoneCtrl.text};
      await DataSp.putLoginCertificate(data);
      await DataSp.putLoginAccount(account);
      Logger.print('login : ${data.userID}, token: ${data.imToken}');
      try {
        await imLogic.login(data.userID, data.imToken);
      } catch (imErr, imStack) {
        // IM 长连接登录失败（此前这里静默无提示）：给中文提示，避免英文/无反馈
        Logger.print('im login failed e: $imErr $imStack');
        IMViews.showToast('登录服务连接失败，请检查网络后重试');
        return false;
      }
      Logger.print('im login success');
      pushLogic.login(data.userID);
      Logger.print('push login success');
      return true;
    } catch (e, s) {
      // 账号接口错误已由 HttpUtil 统一弹中文提示，这里只记录日志，避免重复弹窗
      Logger.print('login e: $e $s');
    }
    return false;
  }

  void togglePasswordType() {
    // 仅支持密码登录，禁用切换
    isPasswordLogin.value = true;
  }

  void toggleLoginType() {
    // 注释掉邮箱登录功能，只保留手机号登录
    // if (loginType.value == LoginType.phone) {
    //   loginType.value = LoginType.email;
    // } else {
    //   loginType.value = LoginType.phone;
    // }

    // phoneCtrl.text = '';
  }

  Future<bool> getVerificationCode() async {
    // 修改手机号校验规则：至少6个字符即可
    if (phone?.isNotEmpty == true && phoneCtrl.text.trim().length < 6) {
      IMViews.showToast('手机号必须至少6个字符');
      return false;
    }

    if (email?.isNotEmpty == true && !phoneCtrl.text.isEmail) {
      IMViews.showToast(StrRes.plsEnterRightEmail);
      return false;
    }

    return sendVerificationCode();
  }

  /// [usedFor] 1：注册，2：重置密码 3：登录
  Future<bool> sendVerificationCode() => LoadingView.singleton.wrap(
      asyncFunction: () => Apis.requestVerificationCode(
            areaCode: areaCode.value,
            phoneNumber: phone,
            email: email,
            usedFor: 3,
          ));

  void openCountryCodePicker() async {
    String? code = await IMViews.showCountryCodePicker();
    if (null != code) areaCode.value = code;
  }

  void configService() => Get.to(
        () => ServerConfigPage(),
        binding: ServerConfigBinding(),
      );

  void registerNow() => AppNavigator.startRegister();

  void forgetPassword() => AppNavigator.startForgetPassword();

  void getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final version = packageInfo.version;
    final appName = packageInfo.appName;
    final buildNumber = packageInfo.buildNumber;

    versionInfo.value = '微聊';
  }
}
