import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:openim_common/openim_common.dart';

/// 一期开奖记录（澳门幸运5，lotCode=1060）。
class LotteryDraw {
  final int issue; // 期号
  final String code; // 开奖号码，如 "7,2,2,9,4"
  final int firstNum; // 第一球
  final String drawTime; // 开奖时间

  LotteryDraw({
    required this.issue,
    required this.code,
    required this.firstNum,
    required this.drawTime,
  });

  /// 第一球奇=单，偶=双。
  bool get isDan => firstNum % 2 == 1;

  String get directionLabel => isDan ? '单' : '双';
}

/// 走势图数据源：
/// 1. 从管理后台下发的 client_config 里读取开奖网址（键 lotteryApiUrl）；
/// 2. 按澳门幸运5(1060) 拉取历史开奖，解析出期号/单双。
/// 逻辑对齐参考项目 niuniuqiwei/src-tauri/src/lottery.rs。
class LotteryService {
  LotteryService._();

  /// 固定彩种：澳门幸运5。
  static const int lotCode = 1060;

  // 超时收紧：外网彩票接口偶发缓慢时不长时间卡住走势图刷新（先显缓存，超时即放弃本次静默刷新）。
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 6),
    responseType: ResponseType.json,
  ));

  static String? _cachedUrl;
  static int _cachedUrlAt = 0;

  /// 开奖数据内存缓存：重开群/切群时先秒显上次结果，再后台刷新，避免每次都等外网。
  static List<LotteryDraw> _cachedDraws = [];

  /// 最近一次成功拉到的开奖列表（可能为空）。供界面首帧立即渲染。
  static List<LotteryDraw> get cached => _cachedDraws;

  /// 读取管理后台配置的开奖网址（client_config.lotteryApiUrl）。带 60s 内存缓存。
  static Future<String?> fetchLotteryApiUrl({bool force = false}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (!force && _cachedUrl != null && now - _cachedUrlAt < 60000) {
      return _cachedUrl;
    }
    try {
      final data = await HttpUtil.post(Urls.getClientConfig, showErrorToast: false);
      final config = (data is Map) ? data['config'] : null;
      final url = (config is Map) ? config['lotteryApiUrl']?.toString().trim() : null;
      _cachedUrl = (url == null || url.isEmpty) ? null : url;
      _cachedUrlAt = now;
    } catch (_) {
      // 读取失败：保留旧缓存，不打断界面。
    }
    return _cachedUrl;
  }

  /// 从"网页/接口网址"推导 API 基址：取 origin(scheme://host[:port]) + "/api/ssc"。
  /// 例：https://ugo188.com/lottery/2/1060 → https://ugo188.com/api/ssc
  static String deriveApiBase(String url) {
    var u = url.trim();
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    if (u.isEmpty) return '';
    final schemeIdx = u.indexOf('://');
    String origin;
    if (schemeIdx >= 0) {
      final rest = u.substring(schemeIdx + 3);
      final slash = rest.indexOf('/');
      origin = slash >= 0 ? u.substring(0, schemeIdx + 3 + slash) : u;
    } else {
      origin = u;
    }
    return '$origin/api/ssc';
  }

  /// 拉最新开奖（最新在前）。失败/无数据时返回上次缓存，保证界面不空白。
  ///
  /// 加速点：① 先只拉「今天」，够 30 期就不再拉「昨天」，省掉一次外网往返；
  /// 今天数据不足（凌晨/接口异常）时才并行补拉昨天。② 拉到的结果写入内存缓存，
  /// 重开群时可先秒显缓存再后台刷新。
  /// 走势图数据统一经「本服务器反代」拉取：http://<服务器IP>:9800/api/ssc。
  /// 手机只连自己的服务器；真正的开奖源(原始网址)由服务器按后台 lotteryApiUrl 去拉，后台改网址即生效。
  static String _proxyBase() => 'http://${Config.serverIp}:9800/api/ssc';

  static Future<List<LotteryDraw>> fetchLatest({int limit = 120}) async {
    final base = _proxyBase();

    final now = DateTime.now();
    final merged = <int, LotteryDraw>{};
    for (final d in await _fetchHistory(base, _fmtDate(now))) {
      merged[d.issue] = d;
    }
    // 今天期数不够（跨天/接口空），才补拉昨天（此时才多花一次请求）。
    if (merged.length < 30) {
      for (final d in await _fetchHistory(base, _fmtDate(now.subtract(const Duration(days: 1))))) {
        merged[d.issue] = d;
      }
    }

    final result = merged.values.toList()..sort((a, b) => b.issue.compareTo(a.issue));
    final out = result.length > limit ? result.sublist(0, limit) : result;
    if (out.isNotEmpty) {
      _cachedDraws = out; // 只在有数据时更新缓存，接口偶发失败不清空已有走势
    }
    return out.isNotEmpty ? out : _cachedDraws;
  }

  /// 拉某一天的历史开奖列表。date 形如 "2026-06-05"。
  static Future<List<LotteryDraw>> _fetchHistory(String base, String date) async {
    try {
      final resp = await _dio.get('$base/queryHistoryList/$lotCode/$date');
      final body = resp.data;
      final map = body is Map ? body : (body is String ? _tryJson(body) : null);
      if (map == null) return [];
      final result = map['result'];
      if (result is! List) return [];
      final out = <LotteryDraw>[];
      for (final item in result) {
        if (item is! Map) continue;
        final code = _str(item['preDrawCode']);
        out.add(LotteryDraw(
          issue: _int(item['preDrawIssue']),
          code: code,
          firstNum: _firstNum(item, code),
          drawTime: _str(item['preDrawTime']),
        ));
      }
      out.sort((a, b) => b.issue.compareTo(a.issue));
      return out;
    } catch (_) {
      return [];
    }
  }

  static Map? _tryJson(String s) {
    try {
      final v = jsonDecode(s);
      return v is Map ? v : null;
    } catch (_) {
      return null;
    }
  }

  /// 优先用 firstNum 字段，否则取开奖号码第一球。
  static int _firstNum(Map item, String code) {
    final n = _int(item['firstNum']);
    if (n > 0 || (n == 0 && code.trim().startsWith('0'))) return n;
    return _firstOfCode(code);
  }

  static int _firstOfCode(String code) {
    final parts = code.split(',');
    if (parts.isEmpty) return 0;
    return int.tryParse(parts.first.trim()) ?? 0;
  }

  static String _fmtDate(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  static String _str(dynamic v) => v == null ? '' : v.toString();

  static int _int(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}
