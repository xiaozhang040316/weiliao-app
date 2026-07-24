import 'package:openim_common/openim_common.dart';
import 'package:permission_handler/permission_handler.dart';

class Permissions {
  Permissions._();

  /// 权限被永久拒绝时，提示并引导用户去系统设置手动开启。
  static void _guideToSettings(String tips) {
    IMViews.showToast(tips);
    openAppSettings();
  }

  static Future<bool> checkSystemAlertWindow() async {
    return Permission.systemAlertWindow.isGranted;
  }

  /// 请求悬浮窗权限（仅在需要时调用，如通话功能）
  static Future<bool> requestSystemAlertWindow() async {
    final status = await Permission.systemAlertWindow.request();
    return status.isGranted;
  }

  static Future<bool> checkStorage() async {
    return await Permission.storage.isGranted;
  }

  static void camera(Function()? onGranted) async {
    if (await Permission.camera.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      onGranted?.call();
    }
    if (await Permission.camera.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
    }
  }

  static void storage(Function()? onGranted) async {
    if (await Permission.storage.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      onGranted?.call();
    }
    if (await Permission.storage.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
    }
  }

  static void manageExternalStorage(Function()? onGranted) async {
    if (await Permission.manageExternalStorage.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      onGranted?.call();
    }
    if (await Permission.storage.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
    }
  }

  static void microphone(Function()? onGranted) async {
    if (await Permission.microphone.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      onGranted?.call();
    }
    if (await Permission.microphone.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
    }
  }

  static void location(Function()? onGranted) async {
    if (await Permission.location.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      onGranted?.call();
    }
    if (await Permission.location.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
    }
  }

  static void speech(Function()? onGranted) async {
    if (await Permission.speech.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      onGranted?.call();
    }
    if (await Permission.speech.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
    }
  }

  static void photos(Function()? onGranted) async {
    final status = await Permission.photos.request();
    // iOS 14+ 用户选择「选中照片(有限访问)」时状态为 limited，
    // 旧代码只判断 isGranted 会把 limited 当作未授权，导致相册无法打开。
    if (status.isGranted || status.isLimited) {
      onGranted?.call();
    } else if (status.isPermanentlyDenied) {
      // 已被永久拒绝：只能去系统设置手动开启
      _guideToSettings('无法访问相册，请在系统设置中开启相册权限后重试');
    }
  }

  static Future<bool> notification() async {
    if (await Permission.notification.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      return true;
    }
    if (await Permission.notification.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
    }

    return false;
  }

  static void ignoreBatteryOptimizations(Function()? onGranted) async {
    if (await Permission.ignoreBatteryOptimizations.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      onGranted?.call();
    }
    if (await Permission.ignoreBatteryOptimizations.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
    }
  }

  static void cameraAndMicrophone(Function()? onGranted) async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
      // Permission.speech,
    ];
    bool isAllGranted = true;
    for (var permission in permissions) {
      final state = await permission.request();
      isAllGranted = isAllGranted && state.isGranted;
    }
    if (isAllGranted) {
      onGranted?.call();
    }
  }

  static Future<bool> media() async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.photos,
    ];
    bool isAllGranted = true;
    for (var permission in permissions) {
      final state = await permission.request();
      // 相册在 iOS 14+ 的 limited(有限访问) 也视为可用
      final ok = state.isGranted || (permission == Permission.photos && state.isLimited);
      isAllGranted = isAllGranted && ok;
    }

    return Future.value(isAllGranted);
  }

  static void storageAndMicrophone(Function()? onGranted) async {
    final permissions = [
      Permission.storage,
      Permission.microphone,
      // Permission.speech,
    ];
    bool isAllGranted = true;
    for (var permission in permissions) {
      final state = await permission.request();
      isAllGranted = isAllGranted && state.isGranted;
    }
    if (isAllGranted) {
      onGranted?.call();
    }
  }

  static Future<Map<Permission, PermissionStatus>> request(List<Permission> permissions) async {
    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await permissions.request();
    return statuses;
  }
}
