import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:openim_common/openim_common.dart';
import 'package:path_provider/path_provider.dart';

class Config {
  //初始化全局信息
  static Future init(Function() runApp) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      final path = (await getApplicationDocumentsDirectory()).path;
      cachePath = '$path/';
      await DataSp.init();
      await Hive.initFlutter(path);
      // await SpeechToTextUtil.instance.initSpeech();
      HttpUtil.init();
    } catch (_) {}

    runApp();

    // 设置屏幕方向
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // 状态栏透明（Android）
    var brightness = Platform.isAndroid ? Brightness.dark : Brightness.light;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: brightness,
      statusBarIconBrightness: brightness,
    ));

    FlutterBugly.init(androidAppId: "", iOSAppId: "");
  }

  static late String cachePath;
  static const uiW = 375.0;
  static const uiH = 812.0;

  /// 默认公司配置
  static const String deptName = "微聊";
  static const String deptID = '0';

  /// 全局字体size
  static const double textScaleFactor = 1.0;

  /// 秘钥
  static const secret = 'tuoyun';

  ///务必更换为自己高德地图的key
  static const webKey = '11111111111111';
  static const webServerKey = '22222222222222222';
  static const locationHost = 'https://203.56.175.233:8444';

  /// 离线消息默认类型
  static OfflinePushInfo offlinePushInfo = OfflinePushInfo(
    title: StrRes.offlineMessage,
    desc: "",
    iOSBadgeCount: true,
    iOSPushSound: '+1',
  );

  /// 二维码：scheme
  static const friendScheme = "io.openim.app/addFriend/";
  static const groupScheme = "io.openim.app/joinGroup/";

  /// ip
  /// web.rentsoft.cn
  /// 203.56.175.233
  static const _host = "155.103.156.46";

  /// 强制使用HTTPS协议
  static const bool useHttps = false;

  /// 服务器IP
  static String get serverIp {
    String? ip;
    var server = DataSp.getServerConfig();
    if (null != server) {
      ip = server['serverIP'];
      Logger.print('缓存serverIP: $ip');
    }
    return ip ?? _host;
  }

  /// 商业版管理后台
  /// $apiScheme://$host/complete_admin/
  /// $apiScheme://$host:10009
  /// 端口：10009
  // static String get chatTokenUrl {
  //   String? url;
  //   var server = DataSp.getServerConfig();
  //   if (null != server) {
  //     url = server['chatTokenUrl'];
  //     Logger.print('缓存chatTokenUrl: $url');
  //   }
  //   return url ??
  //       (_isIP ? "http://$_host:10009" : "https://$_host/complete_admin");
  // }

  /// 登录注册手机验 证服务器地址
  /// $apiScheme://$host/chat/
  /// $apiScheme://$host:10008
  /// 端口：10008
  static String get appAuthUrl {
    String? url;
    var server = DataSp.getServerConfig();
    if (null != server) {
      url = server['authUrl'];
      Logger.print('缓存authUrl: $url');
    }
    // to b
    // return url ??
    //     (_isIP ? "http://$_host:10010" : "https://$_host/organization");
    // to c
    return url ?? (useHttps ? "https://$_host/chat" : "http://$_host:10008");
  }

  /// IM sdk api地址
  /// $apiScheme://$host/api/
  /// $apiScheme://$host:10002
  /// 端口：10002
  static String get imApiUrl {
    String? url;
    var server = DataSp.getServerConfig();
    if (null != server) {
      url = server['apiUrl'];
      Logger.print('缓存apiUrl: $url');
    }
    return url ?? (useHttps ? "https://$_host/api" : 'http://$_host:10002');
  }

  /// IM ws 地址
  /// $socketScheme://$host/msg_gateway
  /// $socketScheme://$host:10001
  /// 端口：10001
  static String get imWsUrl {
    String? url;
    var server = DataSp.getServerConfig();
    if (null != server) {
      url = server['wsUrl'];
      Logger.print('缓存wsUrl: $url');
    }
    return url ?? (useHttps ? "wss://$_host/msg_gateway" : "ws://$_host:10001");
  }

  /// 图片存储
  static String get objectStorage {
    String? storage;
    var server = DataSp.getServerConfig();
    if (null != server) {
      storage = server['objectStorage'];
      Logger.print('缓存objectStorage: $storage');
    }
    return storage ?? 'minio';
  }
}
