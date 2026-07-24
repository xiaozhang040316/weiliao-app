import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
// import 'package:sprintf/sprintf.dart'; // 暂时不需要，因为相关功能被禁用

import 'login_logic.dart';

class LoginPage extends StatelessWidget {
  final logic = Get.find<LoginLogic>();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: TouchCloseSoftKeyboard(
        isLightBlueBg: true,
        child: SingleChildScrollView(
            child: Column(
            children: [
              120.verticalSpace,
              // 微聊 标题
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(bottom: 20.h), // 减少底部间距
                child: Text(
                  '微聊',
                  style: TextStyle(
                    fontSize: 36.sp, // 减小字体大小
                    fontWeight: FontWeight.w600,
                    color: Styles.c_0089FF, // 使用全局主色调，跟随主色调变化
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              30.verticalSpace, // 减少间距
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Obx(() => Column(
                      children: [
                        InputBox.account(
                          label: logic.loginType.value.name,
                          hintText: logic.loginType.value.hintText,
                          code: logic.areaCode.value,
                          onAreaCode: null, // 隐藏区号选择器
                          controller: logic.phoneCtrl,
                          keyBoardType: logic.loginType.value == LoginType.phone ? TextInputType.phone : TextInputType.text,
                        ),
                        16.verticalSpace,
                        Offstage(
                          offstage: !logic.isPasswordLogin.value,
                          child: InputBox.password(
                            label: StrRes.password,
                            hintText: StrRes.plsEnterPassword,
                            controller: logic.pwdCtrl,
                          ),
                        ),
                        // 验证码登录已禁用：隐藏验证码输入框
                        // Offstage(
                        //   offstage: logic.isPasswordLogin.value,
                        //   child: InputBox.verificationCode(
                        //     label: StrRes.verificationCode,
                        //     hintText: StrRes.plsEnterVerificationCode,
                        //     controller: logic.verificationCodeCtrl,
                        //     // onSendVerificationCode: logic.getVerificationCode, // 原来的方法，暂时禁用
                        //     onSendVerificationCode: _showFeatureNotAvailable, // 拦截验证码发送
                        //   ),
                        // ),
                        10.verticalSpace,
                        Row(
                          children: [
                            // 注释掉忘记密码功能
                            // StrRes.forgetPassword.toText
                            //   ..style = Styles.ts_0089FF_12sp // 使用主色调蓝色
                            //   // ..onTap = _showForgetPasswordBottomSheet // 原来的方法，暂时禁用
                            //   ..onTap = _showFeatureNotAvailable, // 拦截忘记密码功能
                            const SizedBox(), // 占位符
                            const Spacer(),
                            // 注释掉邮箱登录切换功能
                            // logic.loginType.value.exclusiveName.toText
                            //   ..style = Styles.ts_8E9AB0_12sp
                            //   // ..onTap = logic.toggleLoginType // 原来的方法，暂时禁用
                            //   ..onTap = _showFeatureNotAvailable, // 拦截切换登录类型功能
                            // 8.horizontalSpace,
                            // 移除“验证码登录/密码登录”切换入口，仅保留密码登录
                            // (logic.isPasswordLogin.value ? StrRes.verificationCodeLogin : StrRes.passwordLogin).toText
                            //   ..style = Styles.ts_8E9AB0_12sp
                            //   // ..onTap = logic.togglePasswordType // 原来的方法，暂时禁用
                            //   ..onTap = _showFeatureNotAvailable, // 拦截切换密码/验证码登录功能
                          ],
                        ),
                        46.verticalSpace,
                        Button(
                          text: StrRes.login,
                          enabled: logic.enabled.value,
                          onTap: logic.login,
                          radius: 12.r, // 稍微加大圆角，与输入框保持一致
                        ),
                      ],
                    )),
              ),
              46.verticalSpace,
              // 简洁的注册链接
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: StrRes.noAccountYet,
                    style: Styles.ts_8E9AB0_14sp,
                    children: [
                      TextSpan(
                        text: ' ${StrRes.registerNow}',
                        style: Styles.ts_0089FF_14sp, // 使用主色调蓝色
                        recognizer: TapGestureRecognizer()..onTap = _showRegisterBottomSheet,
                      )
                    ],
                  ),
                ),
              ),
              40.verticalSpace, // 增加底部间距
            ],
          ),
        ),
      ),
    );
  }

  void _showRegisterBottomSheet() {
    // 直接进入手机号注册，不显示选择弹窗
    logic.operateType = LoginType.phone;
    logic.registerNow();
    
    // 注释掉原来的弹窗选择逻辑
    // showCupertinoModalPopup(
    //   context: Get.context!,
    //   builder: (BuildContext context) {
    //     return CupertinoActionSheet(
    //       actions: [
    //         // 手机号注册放到上面
    //         CupertinoActionSheetAction(
    //           onPressed: () {
    //             Navigator.pop(context);
    //             logic.operateType = LoginType.phone;
    //             logic.registerNow();
    //           },
    //           child: Text(
    //             '${StrRes.phoneNumber} ${StrRes.registerNow}',
    //             style: TextStyle(color: Styles.c_FF8A50),
    //           ),
    //         ),
    //         // 邮箱注册放到下面
    //         CupertinoActionSheetAction(
    //           onPressed: () {
    //             Navigator.pop(context);
    //             // logic.operateType = LoginType.email; // 原来的方法，暂时禁用
    //             // logic.registerNow(); // 原来的方法，暂时禁用
    //             _showFeatureNotAvailable(); // 拦截邮箱注册功能
    //           },
    //           child: Text(
    //             '${StrRes.email} ${StrRes.registerNow}',
    //             style: TextStyle(color: Styles.c_FF8A50),
    //           ),
    //         ),
    //       ],
    //       cancelButton: CupertinoActionSheetAction(
    //         onPressed: () {
    //           Navigator.pop(context);
    //         },
    //         child: Text(
    //           StrRes.cancel,
    //           style: TextStyle(color: Styles.c_8E9AB0),
    //         ),
    //       ),
    //     );
    //   },
    // );
  }

  /// 显示功能暂未开放提示
  Future<bool> _showFeatureNotAvailable() async {
    IMViews.showToast('该功能暂未开放');
    return false;
  }

  // 保留原来的忘记密码弹窗方法，暂时不使用
  void _showForgetPasswordBottomSheet() {
    showCupertinoModalPopup(
      context: Get.context!,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                logic.operateType = LoginType.email;
                logic.forgetPassword();
              },
              child: Text(
                '通过邮箱', // 暂时硬编码，避免导入sprintf
                style: TextStyle(color: Styles.c_FF8A50),
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                logic.operateType = LoginType.phone;
                logic.forgetPassword();
              },
              child: Text(
                '通过手机号', // 暂时硬编码，避免导入sprintf
                style: TextStyle(color: Styles.c_FF8A50),
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              StrRes.cancel,
              style: TextStyle(color: Styles.c_8E9AB0),
            ),
          ),
        );
      },
    );
  }
}
