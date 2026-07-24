import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'circle_members_logic.dart';

class CircleMembersPage extends StatelessWidget {
  CircleMembersPage({super.key});

  final logic = Get.find<CircleMembersLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: '圈子成员'),
      body: Obx(() {
        if (logic.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.separated(
          itemCount: logic.members.length,
          separatorBuilder: (_, __) => Divider(height: 1, color: Styles.c_E8EAEF),
          itemBuilder: (_, index) {
            final m = logic.members[index];
            return Slidable(
              enabled: !logic.isSelf(m),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                extentRatio: logic.isOwner ? 0.25 : 0.125,
                children: [
                  SlidableAction(
                    onPressed: (_) => logic.banOrUnban(m),
                    backgroundColor: m.isBanned ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                    icon: m.isBanned ? Icons.lock_open : Icons.block,
                    label: m.isBanned ? '解封' : '封禁',
                  ),
                ],
              ),
              child: ListTile(
                leading: AvatarView(
                  width: 44.w,
                  height: 44.h,
                  url: m.faceURL,
                  text: m.nickname,
                  isCircle: true,
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: (m.nickname?.isNotEmpty == true ? m.nickname! : (m.userID ?? ''))
                          .toText
                        ..style = m.isBanned ? Styles.ts_8E9AB0_16sp : Styles.ts_0C1C33_16sp,
                    ),
                    if (m.isBanned)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: '已封禁'.toText
                          ..style = Styles.ts_FFFFFF_12sp,
                      ),
                  ],
                ),
                subtitle: (m.isAdmin ? '管理员' : '').toText..style = Styles.ts_8E9AB0_12sp,
              ),
            );
          },
        );
      }),
    );
  }
}

