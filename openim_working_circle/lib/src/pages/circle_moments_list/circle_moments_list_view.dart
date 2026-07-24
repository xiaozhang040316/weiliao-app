import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_working_circle/openim_working_circle.dart';
import 'package:openim_working_circle/src/widgets/work_moments_item.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'circle_moments_list_logic.dart';

class CircleMomentsListPage extends StatelessWidget {
  CircleMomentsListPage({super.key});

  final CircleMomentsListLogic logic =
      Get.find(tag: GetTags.circleMoments);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.c_F8F9FA,
      appBar: TitleBar.back(
        title: '圈子',
        right: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 铃铛按钮
            Obx(() => GestureDetector(
              onTap: () => logic.toggleMute(),
              child: logic.isMuted.value
                  ? Container(
                      width: 22.w,
                      height: 22.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Styles.c_0C1C33, width: 1),
                      ),
                      child: Icon(
                        Icons.notifications_off,
                        size: 14.w,
                        color: Styles.c_0C1C33,
                      ),
                    )
                  : Icon(
                      Icons.notifications,
                      size: 22.w,
                      color: Styles.c_0C1C33,
                    ),
            )),
            16.horizontalSpace,
            // 添加按钮
            ImageRes.addBlack.toImage
              ..width = 28.w
              ..height = 28.h
              ..onTap = () async {
            final created = await WNavigator.startCreateCircle();
            if (created == true) logic.refreshAfterCreated();
          },
          ],
        ),
      ),
      floatingActionButton: _publishButton,
      body: Column(
        children: [
          _myCirclesSection,
          _tabBar,
          Divider(height: 1, color: Styles.c_E8EAEF),
          Expanded(
            child: Obx(
              () => SmartRefresher(
                controller: logic.refreshCtrl,
                header: IMViews.buildHeader(),
                footer: IMViews.buildFooter(),
                enablePullUp: true,
                onRefresh: logic.queryList,
                onLoading: logic.loadMore,
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
          ),
        ],
      ),
    );
  }

  Widget get _tabBar => Container(
        color: Styles.c_FFFFFF,
        padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 4.h, bottom: 6.h),
        child: Row(
          children: [
            _tabButton(label: '最新', index: 0),
            24.horizontalSpace,
            _tabButton(label: '我发布的', index: 1),
          ],
        ),
      );

  Widget _tabButton({required String label, required int index}) => Obx(
        () {
          final selected = logic.tabIndex.value == index;
          return GestureDetector(
              onTap: () => logic.switchTab(index),
                child: label.toText
                  ..style = selected
                  ? (Styles.ts_0089FF_16sp.copyWith(fontWeight: FontWeight.w500))
                  : Styles.ts_8E9AB0_16sp,
          );
        },
      );

  Widget _buildCircleTag(WorkMoments info) {
    final text = info.circleName?.isNotEmpty == true
        ? info.circleName!
        : (info.circleID ?? '');
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: ('#$text').toText..style = Styles.ts_8E9AB0_14sp,
    );
  }

  Widget get _myCirclesSection => Obx(() {
        final list = logic.myCircles;
        return Container(
          width: double.infinity,
          color: Styles.c_FFFFFF,
          padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 10.h, bottom: 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  '我的圈子'.toText..style = Styles.ts_0C1C33_14sp,
                  const Spacer(),
                  GestureDetector(
                    onTap: logic.toMyCircles,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        '更多'.toText..style = Styles.ts_8E9AB0_14sp,
                        Icon(Icons.chevron_right, size: 18.w, color: Styles.c_8E9AB0),
                      ],
                    ),
                  ),
                ],
              ),
              8.verticalSpace,
              SizedBox(
                height: 64.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, index) {
                    if (index == 0) {
                      return _circleAvatar(
                        onTap: logic.toJoinCircle,
                        isAdd: true,
                      );
                    }
                    final item = list[index - 1];
                    return _circleAvatar(
                      onTap: () async {
                        final result = await WNavigator.startCircleDetail(circleID: item.circleID ?? '');
                        if (result == true) {
                          // 退出或删除圈子后刷新列表
                          logic.refreshAfterCreated();
                        }
                      },
                      url: item.avatar ?? item.coverUrl,
                    );
                  },
                  separatorBuilder: (_, __) => 6.horizontalSpace,
                  itemCount: (list.length > 10 ? 10 : list.length) + 1,
                ),
              ),
            ],
          ),
        );
      });

  Widget _circleAvatar({
    required VoidCallback onTap,
    String? url,
    bool isAdd = false,
  }) {
    return GestureDetector(
          onTap: onTap,
          child: Container(
        width: 48.w,
        height: 48.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Styles.c_E8EAEF),
          image: (url == null || isAdd)
                  ? null
                  : DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
          color: Styles.c_F8F9FA,
            ),
            child: isAdd
            ? Icon(Icons.add, color: Styles.c_0089FF, size: 24.w)
            : (url == null
                ? Icon(Icons.image_outlined, color: Styles.c_8E9AB0, size: 18.w)
                : null),
        ),
    );
  }

  Widget get _publishButton => Padding(
        padding: EdgeInsets.only(bottom: 24.h, right: 8.w),
        child: FloatingActionButton(
          backgroundColor: Styles.c_0089FF,
          shape: const CircleBorder(),
          mini: false,
          onPressed: () => logic.publishWithoutType(),
          heroTag: 'circle_publish',
          child: Icon(Icons.add, color: Colors.white, size: 30.w),
        ),
      );
}

