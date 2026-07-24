import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_working_circle/src/routes/w_navigator.dart';

import 'my_circles_logic.dart';

class MyCirclesPage extends StatelessWidget {
  MyCirclesPage({super.key});

  final logic = Get.find<MyCirclesLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: '我的圈子'),
      body: Obx(() {
        if (logic.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (logic.circles.isEmpty) {
          return Center(
            child: '暂无圈子'.toText..style = Styles.ts_8E9AB0_14sp,
          );
        }
        return ListView.separated(
          itemCount: logic.circles.length,
          separatorBuilder: (_, __) => Divider(height: 1, color: Styles.c_E8EAEF),
          itemBuilder: (_, index) {
            final item = logic.circles[index];
            return ListTile(
              leading: AvatarView(
                width: 44.w,
                height: 44.h,
                url: item.avatar ?? item.coverUrl,
                text: item.circleName,
              ),
              title: (item.circleName ?? '').toText..style = Styles.ts_0C1C33_16sp,
              subtitle: (item.description ?? '').toText
                ..style = Styles.ts_8E9AB0_12sp
                ..maxLines = 1
                ..overflow = TextOverflow.ellipsis,
              onTap: () async {
                final result = await WNavigator.startCircleDetail(circleID: item.circleID ?? '');
                if (result == true) {
                  // 退出或删除圈子后刷新列表
                  logic.refresh();
                }
              },
            );
          },
        );
      }),
    );
  }
}

