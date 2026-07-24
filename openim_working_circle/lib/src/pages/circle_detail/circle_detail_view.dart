import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_working_circle/src/widgets/work_moments_item.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'circle_detail_logic.dart';

class CircleDetailPage extends StatelessWidget {
  CircleDetailPage({super.key});

  final logic = Get.find<CircleDetailLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: '圈子详情'),
      body: Obx(
        () => Column(
          children: [
            _infoSection,
            Expanded(
              child: SmartRefresher(
                controller: logic.refreshCtrl,
                enablePullUp: true,
                onRefresh: logic.queryList,
                onLoading: logic.loadMore,
                header: IMViews.buildHeader(),
                footer: IMViews.buildFooter(),
                child: ListView.builder(
                  itemCount: logic.workMoments.length,
                  itemBuilder: (_, index) {
                    final info = logic.workMoments[index];
                    return WorkMomentsItem(
                      moments: info,
                      enableSocial: false,
                      bottomExtra: _buildCircleTag(info),
                      onTapAvatar: logic.viewUserProfile,
                      previewPicture: logic.previewPicture,
                      previewVideo: logic.previewVideo,
                      delMoment: logic.deleteCircleMoment,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _infoSection {
    final info = logic.circleInfo.value;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarView(
                width: 56.w,
                height: 56.h,
                url: info?.avatar,
                text: info?.circleName,
                isCircle: true,
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    (info?.circleName ?? '').toText
                      ..style = Styles.ts_0C1C33_16sp_medium,
                    6.verticalSpace,
                    (info?.description ?? '').toText
                      ..style = Styles.ts_8E9AB0_14sp
                      ..maxLines = 2
                      ..overflow = TextOverflow.ellipsis,
                    if ((info?.inviteCodeNum ?? 0) > 0) ...[
                      6.verticalSpace,
                      '需要 ${info!.inviteCodeNum} 张邀请码进圈'.toText
                        ..style = TextStyle(
                          color: const Color(0xFFFF6B00),
                          fontSize: 14.sp,
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          12.verticalSpace,
          Wrap(
            spacing: 8.w,
            runSpacing: 4.h,
                children: [
              TextButton(
                onPressed: logic.canInviteEnabled ? logic.inviteMembers : null,
                child: const Text('邀请'),
              ),
              TextButton(
                onPressed: logic.isSelfBanned ? null : logic.generateInviteCode,
                child: const Text('生成邀请码'),
              ),
                  if (logic.isOwner)
                    TextButton(
                      onPressed: logic.editCircle,
                      child: const Text('编辑'),
                    ),
                  if (logic.isOwner)
                    TextButton(
                      onPressed: logic.deleteCircle,
                      child: const Text('解散'),
                    ),
                  if (!logic.isOwner)
                    TextButton(
                      onPressed: logic.quitCircle,
                      child: const Text('退出'),
                    ),
              TextButton(
                onPressed: logic.viewMembers,
                child: const Text('查看成员'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleTag(WorkMoments info) {
    final text = info.circleName?.isNotEmpty == true
        ? info.circleName!
        : '';
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: ('#$text').toText..style = Styles.ts_8E9AB0_14sp,
    );
  }
}

