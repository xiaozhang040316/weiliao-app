import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/core/controller/im_controller.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sprintf/sprintf.dart';

import 'conversation_logic.dart';

class ConversationPage extends StatelessWidget {
  final logic = Get.find<ConversationLogic>();
  final im = Get.find<IMController>();

  ConversationPage({super.key});

  // VIP判断已移除，所有用户都可以使用全部功能

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: Styles.c_F8F9FA,
          appBar: TitleBar.conversation(
              statusStr: logic.imSdkStatus,
              isFailed: logic.isFailedSdkStatus,
              popCtrl: logic.popCtrl,
              onClickCallBtn: logic.viewCallRecords,
              onScan: logic.scan,
              onAddFriend: logic.addFriend,
              onAddGroup: logic.addGroup,
              onCreateGroup: logic.createGroup,
              onSearch: logic.globalSearch, // 添加搜索功能
              showCreateGroup: true,
              left: Expanded(
                flex: 2,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    AvatarView(
                      width: 36.w, // 从42.w调小到36.w
                      height: 36.h, // 从42.h调小到36.h
                      text: im.userInfo.value.nickname,
                      url: im.userInfo.value.faceURL,
                    ),
                    10.horizontalSpace,
                    if (null != im.userInfo.value.nickname)
                      Flexible(
                        child: im.userInfo.value.nickname!.toText
                          ..style = Styles.ts_0C1C33_17sp
                          ..maxLines = 1
                          ..overflow = TextOverflow.ellipsis,
                      ),
                    10.horizontalSpace,
                    if (null != logic.imSdkStatus)
                      Flexible(
                          child: SyncStatusView(
                        isFailed: logic.isFailedSdkStatus,
                        statusStr: logic.imSdkStatus!,
                      )),
                  ],
                ),
              )),
          // backgroundColor: Styles.c_FFFFFF,
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SmartRefresher(
                      controller: logic.refreshController,
                      header: IMViews.buildHeader(),
                      footer: IMViews.buildFooter(),
                      enablePullUp: true,
                      enablePullDown: true,
                      onRefresh: logic.onRefresh,
                      onLoading: logic.onLoading,
                      child: ListView.builder(
                        itemCount: logic.list.length,
                        controller: logic.scrollController,
                        itemExtent: 68.h, // 固定高度优化性能
                        cacheExtent: 500, // 缓存更多项目
                        itemBuilder: (_, index) => AutoScrollTag(
                          key: ValueKey(logic.list.elementAt(index).conversationID),
                          controller: logic.scrollController,
                          index: index,
                          child: _buildConversationItemView(
                            logic.list.elementAt(index),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // 同步消息期间：不透明遮罩+刷新动画，挡住会话列表并拦截点击，防止误进群操作。
              if (logic.showSyncMask.value) _buildSyncingMask(),
            ],
          ),
        ));
  }

  /// 同步中遮罩：覆盖整个会话列表，吸收所有点击，展示刷新动画与提示。
  Widget _buildSyncingMask() => Positioned.fill(
        child: AbsorbPointer(
          absorbing: true,
          child: Container(
            color: Styles.c_F8F9FA,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 40.w,
                  height: 40.w,
                  child: CircularProgressIndicator(strokeWidth: 3.w, color: Styles.c_0089FF),
                ),
                20.verticalSpace,
                ('正在同步消息，请稍候…'.toText..style = Styles.ts_0C1C33_17sp),
                10.verticalSpace,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: ('同步完成前请勿进入群聊，避免消息未加载完成导致误操作'.toText
                    ..style = Styles.ts_8E9AB0_14sp
                    ..textAlign = TextAlign.center),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildConversationItemView(ConversationInfo info) => RepaintBoundary(
        child: GestureDetector(
          onLongPress: () => _showConversationMenu(info),
          child: _buildItemView(info),
        ),
      );

  void _showConversationMenu(ConversationInfo info) async {
    final items = <SheetItem>[];

    // 置顶/取消置顶
    items.add(SheetItem(
      label: logic.isPinned(info) ? StrRes.cancelTop : StrRes.top,
      result: 'pin',
    ));

    // 标记已读（仅在有未读消息时显示）
    if (logic.existUnreadMsg(info)) {
      items.add(SheetItem(
        label: StrRes.markHasRead,
        result: 'markRead',
      ));
    }

    // 删除
    items.add(SheetItem(
      label: StrRes.delete,
      result: 'delete',
      textStyle: Styles.ts_FF381F_17sp,
    ));

    final result = await Get.bottomSheet(
      BottomSheetView(items: items),
    );

    switch (result) {
      case 'pin':
        logic.pinConversation(info);
        break;
      case 'markRead':
        logic.markMessageHasRead(info);
        break;
      case 'delete':
        logic.deleteConversation(info);
        break;
    }
  }

  Widget _buildItemView(ConversationInfo info) => Ink(
        child: InkWell(
          onTap: () => logic.toChat(conversationInfo: info),
          child: Stack(
            children: [
              Container(
                height: 68.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        AvatarView(
                          width: 48.w,
                          height: 48.h,
                          text: logic.getShowName(info),
                          url: info.faceURL,
                          isGroup: logic.isGroupChat(info),
                          textStyle: Styles.ts_FFFFFF_14sp_medium,
                        ),
                        // if (logic.isNotDisturb(info) &&
                        //     logic.getUnreadCount(info) > 0)
                        //   Transform.translate(
                        //     offset: Offset(42.h, -2),
                        //     child: const RedDotView(),
                        //   ),
                      ],
                    ),
                    12.horizontalSpace,
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 180.w),
                                child: logic.getShowName(info).toText
                                  ..style = Styles.ts_0C1C33_17sp
                                  ..maxLines = 1
                                  ..overflow = TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              logic.getTime(info).toText..style = Styles.ts_8E9AB0_12sp,
                            ],
                          ),
                          3.verticalSpace,
                          Row(
                            children: [
                              MatchTextView(
                                text: logic.getContent(info),
                                textStyle: Styles.ts_8E9AB0_14sp,
                                allAtMap: logic.getAtUserMap(info),
                                prefixSpan: TextSpan(
                                  text: '',
                                  children: [
                                    if (logic.isNotDisturb(info) && logic.getUnreadCount(info) > 0)
                                      TextSpan(
                                        text: '[${sprintf(StrRes.nPieces, [logic.getUnreadCount(info)])}] ',
                                        style: Styles.ts_8E9AB0_14sp,
                                      ),
                                    TextSpan(
                                      text: logic.getPrefixTag(info),
                                      style: Styles.ts_0089FF_14sp,
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                patterns: <MatchPattern>[
                                  MatchPattern(
                                    type: PatternType.at,
                                    style: Styles.ts_8E9AB0_14sp,
                                  ),
                                ],
                              ),
                              // logic.getMsgContent(info).toText
                              //   ..style = Styles.ts_8E9AB0_14sp,
                              const Spacer(),
                              if (logic.isNotDisturb(info))
                                ImageRes.notDisturb.toImage
                                  ..width = 13.63.w
                                  ..height = 14.07.h
                              else
                                UnreadCountView(count: logic.getUnreadCount(info)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (logic.isPinned(info))
                Container(
                  height: 68.h,
                  margin: EdgeInsets.only(right: 6.w),
                  foregroundDecoration: RotatedCornerDecoration.withColor(
                    color: Styles.c_0089FF,
                    badgeSize: Size(8.29.w, 8.29.h),
                  ),
                )
            ],
          ),
        ),
      );
}
