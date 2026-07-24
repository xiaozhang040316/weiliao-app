import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../contacts/contacts_view.dart';
import '../conversation/conversation_view.dart';
import '../mine/mine_view.dart';
// import '../workbench/workbench_view.dart'; // 工作台页面暂时隐藏
import 'home_logic.dart';

class HomePage extends StatelessWidget {
  final logic = Get.find<HomeLogic>();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: Styles.c_FFFFFF,
          body: IndexedStack(
            index: logic.index.value,
            children: [
              ConversationPage(),
              ContactsPage(),
              // WorkbenchPage(),  // 工作台页面暂时隐藏，以后可能有用
              MinePage(),
            ],
          ),
          bottomNavigationBar: SafeArea(child:  BottomBar(
            index: logic.index.value,
            items: [
              BottomBarItem(
                selectedImgRes: ImageRes.homeTab1Sel,
                unselectedImgRes: ImageRes.homeTab1Nor,
                label: StrRes.home,
                imgWidth: 28.w,
                imgHeight: 28.h,
                onClick: logic.switchTab,
                onDoubleClick: logic.scrollToUnreadMessage,
                count: logic.unreadMsgCount.value,
              ),
              BottomBarItem(
                selectedImgRes: ImageRes.homeTab2Sel,
                unselectedImgRes: ImageRes.homeTab2Nor,
                label: StrRes.contacts,
                imgWidth: 28.w,
                imgHeight: 28.h,
                onClick: logic.switchTab,
                count: logic.unhandledCount.value,
              ),
              // 工作台tab暂时隐藏，以后可能有用
              // BottomBarItem(
              //   selectedImgRes: ImageRes.homeTab3Sel,
              //   unselectedImgRes: ImageRes.homeTab3Nor,
              //   label: StrRes.workbench,  // 恢复工作台
              //   imgWidth: 28.w,
              //   imgHeight: 28.h,
              //   onClick: logic.switchTab,
              // ),
              BottomBarItem(
                selectedImgRes: ImageRes.homeTab4Sel,
                unselectedImgRes: ImageRes.homeTab4Nor,
                label: StrRes.mine,
                imgWidth: 28.w,
                imgHeight: 28.h,
                onClick: logic.switchTab,
              ),
            ],
          ),
        )));
  }
}
