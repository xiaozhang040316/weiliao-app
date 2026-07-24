import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_working_circle/openim_working_circle.dart';
import 'package:openim_working_circle/src/pages/work_moments_list/work_moments_list_logic.dart';
import 'package:openim_working_circle/src/w_apis.dart';
import 'package:sprintf/sprintf.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import '../publish/publish_logic.dart';

class PublishCircleLogic extends GetxController {
  PublishCircleLogic();

  final inputCtrl = TextEditingController();
  final focusNode = FocusNode();
  late PublishType type;
  final assetsList = <AssetEntity>[].obs;
  BaseDeviceInfo? deviceInfo;
  final watchList = <dynamic>[].obs;
  final remindList = <dynamic>[].obs;
  final permission = 0.obs;
  final circles = <CircleInfo>[].obs;
  final selectedCircle = Rxn<CircleInfo>();

  WorkingCircleBridge? get bridge => PackageBridge.workingCircleBridge;

  SelectContactsBridge? get contactsBridge => PackageBridge.selectContactsBridge;

  @override
  void onClose() {
    inputCtrl.dispose();
    focusNode.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    type = Get.arguments['type'] ?? PublishType.picture;
    _initDeviceInfo();
    _loadCircles();
    super.onInit();
  }

  Future<void> _loadCircles() async {
    try {
      final list = await WApis.getCircleList();
      circles.assignAll(list);
      if (list.isNotEmpty) {
        selectedCircle.value = list.first;
      }
    } catch (e) {
      Logger.print('加载圈子列表失败: $e');
    }
  }

  Future<void> _initDeviceInfo() async {
    if (null == deviceInfo) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      deviceInfo = await deviceInfoPlugin.deviceInfo;
    }
  }

  bool get isPicture => type == PublishType.picture;

  int get maxAssetsCount => isPicture ? 9 : 1;

  int get btnLength =>
      isPicture ? (assetsList.length < maxAssetsCount ? 1 : 0) : (assetsList.isEmpty ? 1 : 0);

  bool showAddAssetsBtn(index) =>
      (assetsList.length < maxAssetsCount) && (index == (assetsList.length + btnLength) - 1);

  void selectAssets() {
    // 如果已经选择了资源，说明类型已确定，直接显示来源选择
    if (assetsList.isNotEmpty) {
      _showSelectSourceSheet();
      return;
    }
    // 如果还没有选择资源，先选择类型
    Get.bottomSheet(
      BottomSheetView(
        items: [
          SheetItem(
            label: StrRes.publishPicture,
            onTap: () {
              final oldType = type;
              type = PublishType.picture;
              if (oldType != type) {
                assetsList.clear();
              }
              Future.delayed(const Duration(milliseconds: 300), () {
                _showSelectSourceSheet();
              });
            },
          ),
          SheetItem(
            label: StrRes.publishVideo,
            onTap: () {
              final oldType = type;
              type = PublishType.video;
              if (oldType != type) {
                assetsList.clear();
              }
              Future.delayed(const Duration(milliseconds: 300), () {
                _showSelectSourceSheet();
              });
            },
          ),
        ],
      ),
    );
  }

  void _showSelectSourceSheet() => Get.bottomSheet(
        BottomSheetView(
          items: [
            SheetItem(
              label: StrRes.selectAssetsFromCamera,
              onTap: () {
                _selectAssetsFromCamera();
              },
            ),
            SheetItem(
              label: StrRes.selectAssetsFromAlbum,
              onTap: () {
                _selectAssetsFromAlbum();
              },
            ),
          ],
        ),
      );

  Future<void> _selectAssetsFromAlbum() async {
    Permissions.storage(() async {
      final count = maxAssetsCount - assetsList.length;

      final List<AssetEntity>? assets = await AssetPicker.pickAssets(
        Get.context!,
        pickerConfig: AssetPickerConfig(
          selectedAssets: assetsList,
          maxAssets: maxAssetsCount,
          requestType: isPicture ? RequestType.image : RequestType.video,
          selectPredicate: (_, entity, __) {
            if (type == PublishType.video && entity.videoDuration > const Duration(seconds: 15)) {
              IMViews.showToast('${sprintf(StrRes.selectVideoLimit, [15])}${StrRes.seconds}');
              return false;
            }
            return true;
          },
        ),
      );
      if (null != assets) {
        assetsList.assignAll(assets.take(count));
      }
    });
  }

  Future<void> _selectAssetsFromCamera() async {
    Permissions.camera(() async {
      final AssetEntity? assetEntity = await CameraPicker.pickFromCamera(
        Get.context!,
        locale: Get.locale,
        pickerConfig: CameraPickerConfig(
          enableAudio: true,
          enableScaledPreview: true,
          resolutionPreset: ResolutionPreset.medium,
          maximumRecordingDuration: 15.seconds,
          onlyEnableRecording: type == PublishType.video,
          enableRecording: type == PublishType.video,
          onMinimumRecordDurationNotMet: () {
            IMViews.showToast(StrRes.tapTooShort);
          },
        ),
      );

      if (null != assetEntity) {
        assetsList.add(assetEntity);
      }
    });
  }

  void previewSelectedPicture(int index) =>
      isPicture ? WNavigator.startPreviewSelectedPicture(currentIndex: index) : WNavigator.startPreviewSelectedVideo();

  void deleteAssets(int index) {
    assetsList.removeAt(index);
  }

  /// 0/1/2/3, 公开/私密/部分可见/不给谁看
  Future<void> whoCanWatch() async {
    final result = await WNavigator.startWhoCanWatch(
      permission: permission.value,
      checkedList: watchList.value,
    );
    if (result is Map) {
      permission.value = result['permission'];
      watchList.assignAll(result['checkedList']);
    }
  }

  Future<void> remindWhoToWatch() async {
    final result = await contactsBridge?.selectContacts(1, checkedList: remindList);
    if (result is Map) {
      final values = result.values;
      remindList.assignAll(values);
    }
  }

  String get whoCanWatchLabel {
    if (permission.value == 3) {
      return StrRes.partiallyInvisible;
    }
    return StrRes.whoCanWatch;
  }

  String get whoCanWatchValue {
    if (permission.value == 0) {
      return StrRes.public;
    } else if (permission.value == 1) {
      return StrRes.private;
    } else if (permission.value == 2) {
      return watchList.map((e) => parseName(e)).join('、');
    } else if (permission.value == 3) {
      return watchList.map((e) => parseName(e)).join('、');
    }
    return '';
  }

  String get remindWhoToWatchValue {
    return remindList.map((e) => parseName(e)).join('、');
  }

  String? parseName(value) {
    if (value is UserInfo) {
      return value.nickname;
    } else if (value is GroupInfo) {
      return value.groupName;
    } else if (value is ISUserInfo) {
      return value.nickname;
    }
    return null;
  }

  Future<void> chooseCircle() async {
    final result = await WNavigator.startSelectCircle<CircleInfo>();
    if (result != null) {
      selectedCircle.value = result;
    }
  }

  Future<void> publish() async {
    if (selectedCircle.value == null) {
      IMViews.showToast('请选择圈子');
      return;
    }
    if (inputCtrl.text.trim().isEmpty) {
      focusNode.requestFocus();
      IMViews.showToast(StrRes.plsEnterDescription);
      return;
    }
    await LoadingView.singleton.wrap(asyncFunction: () async {
      final permissionUserList = <UserInfo>[];
      final permissionGroupList = <GroupInfo>[];
      final atUserList = <UserInfo>[];
      for (final info in watchList) {
        if (info is GroupInfo) {
          permissionGroupList.add(info);
        } else {
          permissionUserList.add(UserInfo(userID: info.userID, nickname: info.nickname, faceURL: info.faceURL));
        }
      }
      for (final info in remindList) {
        atUserList.add(UserInfo(userID: info.userID, nickname: info.nickname, faceURL: info.faceURL));
      }

      final metas = <Map<String, String>>[];

      await Future.forEach<AssetEntity>(assetsList.value, (element) async {
        var file = await element.file;
        if (type == PublishType.picture) {
          final mime = IMUtils.getMediaType(file!.path);
          if (mime == 'image/gif') {
            metas.add({'thumb': file.path, 'original': file.path});
          } else {
            file = await IMUtils.compressImageAndGetFile(file);
            metas.add({'thumb': file!.path, 'original': file.path});
          }
        } else {
          file = await IMUtils.compressVideoAndGetFile(file!);
          final thumbPic = await IMUtils.getVideoThumbnail(file!);
          metas.add({'thumb': thumbPic.path, 'original': file.path});
        }
      });

      await WApis.publishMoments(
        text: inputCtrl.text.trim(),
        type: isPicture ? 0 : 1,
        permissionUserList: permissionUserList,
        permissionGroupList: permissionGroupList,
        atUserList: atUserList,
        metas: metas,
        permission: permission.value,
        circleID: selectedCircle.value?.circleID,
        workMomentType: 1,
      );
    });
    bridge?.opEventSub.add({'opEvent': OpEvent.publish});
    Get.back();
  }
}

