import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_working_circle/openim_working_circle.dart';
import 'package:openim_working_circle/src/pages/publish/publish_logic.dart';
import 'package:openim_working_circle/src/pages/work_moments_list/work_moments_list_logic.dart';
import 'package:openim_working_circle/src/pages/work_moments_list/preview_picture/preview_picture_view.dart';
import 'package:openim_working_circle/src/pages/work_moments_list/preview_video/preview_video_view.dart';
import 'package:openim_working_circle/src/w_apis.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CircleMomentsListLogic extends GetxController {
  CircleMomentsListLogic();

  final refreshCtrl = RefreshController();
  final workMoments = <WorkMoments>[].obs;
  final hasMore = true.obs;
  final tabIndex = 0.obs; // 0 最新 1 我发布
  int pageNo = 1;
  final pageSize = 20;
  final myCircles = <CircleInfo>[].obs;
  StreamSubscription? opEventSub;
  StreamSubscription? circleNewMessageSub;
  
  // 圈子动态静音状态（默认不静音）
  final isMuted = false.obs;
  static const String _muteKey = 'circle_moments_muted';

  ViewUserProfileBridge? get bridge => PackageBridge.viewUserProfileBridge;
  WorkingCircleBridge? get wcBridge => PackageBridge.workingCircleBridge;

  NavigatorState? get navigator =>
      Get.context?.findRootAncestorStateOfType<NavigatorState>();

  @override
  void onReady() {
    queryList();
    _loadMyCircles();
    _loadMuteStatus();
    opEventSub = wcBridge?.opEventSub.listen(_onOpEvent);
    // 监听圈子新动态消息
    circleNewMessageSub = wcBridge?.circleNewMessageSub.listen((_) {
      _onRecvCircleNewMessage();
    });
    super.onReady();
  }
  
  /// 加载静音状态
  void _loadMuteStatus() {
    isMuted.value = SpUtil().getBool(_muteKey, defValue: false) ?? false;
  }
  
  /// 切换静音状态
  Future<void> toggleMute() async {
    isMuted.value = !isMuted.value;
    await SpUtil().putBool(_muteKey, isMuted.value);
  }
  
  /// 检查是否静音（供外部调用）
  static bool isCircleMomentsMuted() {
    return SpUtil().getBool(_muteKey, defValue: false) ?? false;
  }

  void _onOpEvent(dynamic event) {
    if (event is Map) {
      final opEvent = event['opEvent'];
      if (opEvent == OpEvent.publish || opEvent == OpEvent.delete) {
        queryList();
      }
    }
  }

  void switchTab(int index) {
    if (tabIndex.value == index) return;
    tabIndex.value = index;
    queryList();
  }

  Future<WorkMomentsList> _request(int page) {
    if (tabIndex.value == 0) {
      return WApis.getMomentsList(
        pageNumber: page,
        showNumber: pageSize,
        workMomentType: 1,
      );
    }
    return WApis.getUserMomentsList(
      userID: OpenIM.iMManager.userID!,
      pageNumber: page,
      showNumber: pageSize,
      workMomentType: 1,
    );
  }

  void queryList() async {
    try {
      final result = await _request(pageNo = 1);
      final list = result.workMoments ?? [];
      hasMore.value = list.isNotEmpty && list.length == pageSize;
      workMoments.assignAll(list);
    } finally {
      refreshCtrl.refreshCompleted();
      if (hasMore.value) {
        refreshCtrl.loadComplete();
      } else {
        refreshCtrl.loadNoData();
      }
    }
  }

  Future<void> _loadMyCircles() async {
    try {
      final list = await WApis.getCircleList(showNumber: 100);
      myCircles.assignAll(list);
    } catch (e) {
      Logger.print('加载圈子列表失败: $e');
    }
  }

  Future<void> toJoinCircle() async {
    final result = await WNavigator.startJoinCircle();
    if (result == true) {
      _loadMyCircles();
    }
  }

  void toMyCircles() => WNavigator.startMyCircles();

  void refreshAfterCreated() => _loadMyCircles();

  @override
  void onClose() {
    opEventSub?.cancel();
    circleNewMessageSub?.cancel();
    refreshCtrl.dispose();
    super.onClose();
  }

  void loadMore() async {
    try {
      final result = await _request(++pageNo);
      final list = result.workMoments ?? [];
      hasMore.value = list.isNotEmpty && list.length == pageSize;
      workMoments.addAll(list);
    } catch (_) {
      pageNo--;
    }
    if (hasMore.value) {
      refreshCtrl.loadComplete();
    } else {
      refreshCtrl.loadNoData();
    }
  }

  void publish(int type) => WNavigator.startPublishCircleMoments(
        type: type == 0 ? PublishType.picture : PublishType.video,
      );

  Future<void> publishWithType(int type) async {
    final result = await WNavigator.startPublishCircleMoments(
      type: type == 0 ? PublishType.picture : PublishType.video,
    );
    if (result == true) {
      queryList();
    }
  }

  Future<void> publishWithoutType() async {
    final result = await WNavigator.startPublishCircleMoments();
    if (result == true) {
      queryList();
    }
  }

  void previewPicture(int index, List<Metas> metas) {
    navigator?.push(TransparentRoute(
      builder: (BuildContext context) => GestureDetector(
        onTap: () => Get.back(),
        child: PreviewPicturePage(
          metas: metas,
          currentIndex: index,
          heroTag: metas.elementAt(index).original,
        ),
      ),
    ));
  }

  void previewVideo(String url, String? coverUrl) {
    navigator?.push(TransparentRoute(
      builder: (BuildContext context) => PreviewVideoPage(
        heroTag: url,
        url: url,
        coverUrl: coverUrl,
      ),
    ));
  }

  void viewUserProfile(WorkMoments moments) => bridge?.viewUserProfile(
        moments.userID!,
        moments.nickname,
        moments.faceURL,
      );

  void viewMyProfilePanel() => bridge?.viewUserProfile(
        OpenIM.iMManager.userID!,
        OpenIM.iMManager.userInfo.nickname,
        OpenIM.iMManager.userInfo.faceURL,
      );

  /// 删除圈子动态
  Future<void> deleteCircleMoment(WorkMoments moments) async {
    await LoadingView.singleton.wrap(
      asyncFunction: () async {
        await WApis.deleteMoments(workMomentID: moments.workMomentID!);
      },
    );
    workMoments.remove(moments);
  }

  /// 收到圈子新动态消息，增量更新列表
  Future<void> _onRecvCircleNewMessage() async {
    // 只在"最新"标签页时进行增量更新
    if (tabIndex.value != 0) return;
    
    try {
      // 获取第一页的最新动态
      final result = await WApis.getMomentsList(
        pageNumber: 1,
        showNumber: pageSize,
        workMomentType: 1,
      );
      final newList = result.workMoments ?? [];
      if (newList.isEmpty) return;

      // 获取当前列表的 workMomentID 集合
      final existingIds = workMoments
          .map((e) => e.workMomentID)
          .where((id) => id != null && id.isNotEmpty)
          .toSet();

      // 过滤出新的动态（不在当前列表中的）
      final toAdd = newList
          .where((e) => e.workMomentID != null && 
                       e.workMomentID!.isNotEmpty && 
                       !existingIds.contains(e.workMomentID))
          .toList();

      if (toAdd.isNotEmpty) {
        // 将新动态插入到列表顶部
        workMoments.insertAll(0, toAdd);
      }
    } catch (e) {
      Logger.print('增量更新圈子动态失败: $e');
    }
  }
}

