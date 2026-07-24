import 'dart:convert';

class ApiResp {
  int errCode;
  String errMsg;
  String errDlt;
  dynamic data;

  ApiResp.fromJson(Map<String, dynamic> map)
      : errCode = map["errCode"] ?? -1,
        errMsg = map["errMsg"] ?? '',
        errDlt = map["errDlt"] ?? '',
        data = map["data"];

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errCode'] = errCode;
    data['errMsg'] = errMsg;
    data['errDlt'] = errDlt;
    data['data'] = data;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class ApiError {
  ApiError._();

  /// 统一错误文案：始终为「[错误码] 中文描述」，不再向用户暴露英文。
  /// [errorCode] 服务端返回的错误码；[rawMsg] 服务端原始 errMsg（仅在无法识别码值时做兜底判断）。
  static String format(int errorCode, [String? rawMsg]) {
    final zh = _errorZH['$errorCode'];
    if (zh != null) return '[$errorCode] $zh';
    return '[$errorCode] ${_genericZH(errorCode)}';
  }

  /// 仅返回中文描述（不含错误码），未知码返回通用中文。
  static String getMsg(int errorCode) => _errorZH['$errorCode'] ?? _genericZH(errorCode);

  /// 未识别错误码时的通用中文兜底（按码段粗分，保证不出现英文）。
  static String _genericZH(int code) {
    if (code >= 1500 && code < 1600) return '登录状态已失效，请重新登录';
    if (code >= 20100 && code < 20200) return '登录状态已失效，请重新登录';
    if (code == 500 || (code >= 10000 && code < 10100)) return '服务器繁忙，请稍后重试';
    return '操作失败，请稍后重试';
  }

  /// 错误码 -> 中文描述。
  /// 覆盖：OpenIM 服务端通用码 / Token 登录态码 / chat 业务码(登录注册验证码等)。
  static const _errorZH = {
    // ===== OpenIM 服务端通用错误 =====
    '500': '服务器内部错误',
    '1001': '请求参数错误',
    '1002': '没有操作权限',
    '1003': '数据已存在',
    '1004': '记录不存在',
    // 用户
    '1101': '用户不存在',
    '1102': '该账号已注册',
    // 群组
    '1201': '群组不存在',
    '1202': '群组已存在',
    '1203': '你已不在该群聊中',
    '1204': '该群已解散',
    '1205': '群主不能退出群聊',
    // 好友/关系
    '1301': '不能添加自己为好友',
    '1302': '你已被对方拉黑',
    '1303': '你们还不是好友',
    '1304': '你们已经是好友',
    // Token / 登录态
    '1501': '登录已过期，请重新登录',
    '1502': '登录凭证无效，请重新登录',
    '1503': '登录凭证异常，请重新登录',
    '1504': '登录凭证尚未生效，请稍后重试',
    '1505': '登录凭证异常，请重新登录',
    '1506': '账号已在其他设备登录',
    '1507': '登录已失效，请重新登录',
    // ===== chat 业务错误（登录/注册/验证码/邀请码）=====
    '20001': '密码错误',
    '20002': '账号不存在',
    '20003': '手机号已注册',
    '20004': '账号已注册',
    '20005': '验证码发送过于频繁，请稍后再试',
    '20006': '验证码错误',
    '20007': '验证码已过期',
    '20008': '验证码错误次数过多，请稍后再试',
    '20009': '验证码已被使用',
    '20010': '邀请码已被使用',
    '20011': '邀请码不存在',
    '20012': '账号已被禁用，请联系管理员',
    '20013': '对方拒绝添加好友',
    '20014': '邮箱已注册',
    '20101': '登录已失效，请重新登录',
  };
}
