import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'about_us_logic.dart';

class AboutUsPage extends StatelessWidget {
  final logic = Get.find<AboutUsLogic>();

  AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: StrRes.aboutUs),
      backgroundColor: Styles.c_F8F9FA,
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Styles.c_FFFFFF,
              borderRadius: BorderRadius.circular(6.r),
            ),
            margin: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 10.h,
            ),
            child: Column(
              children: [
                23.verticalSpace,
                ImageRes.splashLogo.toImage
                  ..width = 55.w
                  ..height = 78.h,
                10.verticalSpace,
                '微聊'.toText
                  ..style = Styles.ts_0C1C33_14sp,
                16.verticalSpace,
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  color: Styles.c_E8EAEF,
                  height: .5,
                ),
                // 隐藏检查更新按钮，避免弹窗干扰用户
                // if (Platform.isAndroid)
                //   GestureDetector(
                //     behavior: HitTestBehavior.translucent,
                //     onTap: logic.checkUpdate,
                //     child: Container(
                //       height: 57.h,
                //       padding: EdgeInsets.symmetric(horizontal: 16.w),
                //       child: Row(
                //         children: [
                //           StrRes.checkNewVersion.toText..style = Styles.ts_0C1C33_17sp,
                //           const Spacer(),
                //           ImageRes.rightArrow.toImage
                //             ..width = 24.w
                //             ..height = 24.h,
                //         ],
                //       ),
                //     ),
                //   ),

                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: logic.uploadLogs,
                  child: Container(
                    height: 57.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        StrRes.uploadErrorLog.toText..style = Styles.ts_0C1C33_17sp,
                        const Spacer(),
                        ImageRes.rightArrow.toImage
                          ..width = 24.w
                          ..height = 24.h,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 使用须知与免责声明
          Container(
            decoration: BoxDecoration(
              color: Styles.c_FFFFFF,
              borderRadius: BorderRadius.circular(6.r),
            ),
            margin: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 10.h,
            ),
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Styles.c_0089FF, size: 18.sp),
                    6.horizontalSpace,
                    '使用须知'.toText..style = Styles.ts_0C1C33_17sp,
                  ],
                ),
                12.verticalSpace,
                Container(
                  decoration: BoxDecoration(
                    color: Styles.c_F8F9FA,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  padding: EdgeInsets.all(12.w),
                  child: Text(
                    '本系统只限抖音切片交流使用，禁止用于任何违法国家法律用途，任何牵涉资金有关的都是骗子，请勿相信！',
                    style: Styles.ts_0C1C33_14sp.copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
