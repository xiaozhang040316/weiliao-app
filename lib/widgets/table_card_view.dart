import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 表格卡片消息渲染（下注清单 / 账单 / 总账单等），原生绘制、可着色，取代图片。
///
/// 自定义消息 data 结构（customType = CustomMessageType.tableCard = 920）：
/// {
///   "cardType": "betList",                 // 可选，仅标识用途
///   "title": "第260721390期 · 开单",         // 抬头标题
///   "subtitle": "2026-07-22 04:31",         // 可选副标题
///   "titleBg": "#122346",                   // 可选抬头背景色(#RRGGBB / #AARRGGBB)
///   "columns": [                            // 列定义
///     {"label":"昵称","flex":3,"align":"left"},
///     {"label":"方向","flex":2,"align":"center"},
///     {"label":"金额","flex":2,"align":"right"}
///   ],
///   "rows": [                               // 数据行
///     {"cells":[
///        {"text":"来日方长"},
///        {"text":"单","color":"#D62828","bold":true},
///        {"text":"100.00"}
///     ]}
///   ],
///   "summary": [                            // 可选汇总行
///     {"label":"单合计","value":"600.00","color":"#D62828"},
///     {"label":"双合计","value":"800.00","color":"#2846D2"}
///   ]
/// }
class TableCardView extends StatelessWidget {
  const TableCardView({super.key, required this.data});

  final Map data;

  static const _headerBg = Color(0xFF122346);
  static const _headerText = Color(0xFFFFFFFF);
  static const _border = Color(0xFFE4E7EC);
  static const _rowAlt = Color(0xFFF7F8FA);
  static const _colHeadBg = Color(0xFFEFF2F6);
  static const _colHeadText = Color(0xFF4A5468);
  static const _textColor = Color(0xFF1A1D24);
  static const _subColor = Color(0xFF8E9AB0);

  @override
  Widget build(BuildContext context) {
    final title = (data['title'] ?? '').toString();
    final subtitle = (data['subtitle'] ?? '').toString();
    final titleRight = (data['titleRight'] ?? '').toString(); // 抬头右侧信息（如"第一球开单 · 3,3,0,6,6"）
    final titleBg = _parseColor(data['titleBg']) ?? _headerBg;
    final columns = (data['columns'] is List) ? data['columns'] as List : const [];
    final rows = (data['rows'] is List) ? data['rows'] as List : const [];
    final summary = (data['summary'] is List) ? data['summary'] as List : const [];
    final flexes = columns
        .map((c) => (c is Map && c['flex'] is num) ? (c['flex'] as num).toInt().clamp(1, 20) : 1)
        .toList();

    final card = Container(
      constraints: BoxConstraints(maxWidth: 0.86.sw),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title.isNotEmpty || subtitle.isNotEmpty || titleRight.isNotEmpty)
            Container(
              width: double.infinity,
              color: titleBg,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty || titleRight.isNotEmpty)
                    Row(
                      children: [
                        Expanded(
                          child: Text(title,
                              style: TextStyle(color: _headerText, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                        ),
                        if (titleRight.isNotEmpty)
                          Text(titleRight,
                              style: TextStyle(color: _headerText, fontSize: 12.5.sp, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  if (subtitle.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(subtitle,
                          style: TextStyle(color: _headerText.withOpacity(0.85), fontSize: 11.sp)),
                    ),
                ],
              ),
            ),
          if (columns.isNotEmpty)
            Container(
              color: _colHeadBg,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 7.h),
              child: Row(
                children: List.generate(columns.length, (i) {
                  final c = columns[i] is Map ? columns[i] as Map : const {};
                  return Expanded(
                    flex: flexes[i],
                    child: Text(
                      (c['label'] ?? '').toString(),
                      textAlign: _align(c['align']),
                      style: TextStyle(color: _colHeadText, fontSize: 12.sp, fontWeight: FontWeight.w600),
                    ),
                  );
                }),
              ),
            ),
          ...List.generate(rows.length, (ri) {
            final row = rows[ri] is Map ? rows[ri] as Map : const {};
            final cells = (row['cells'] is List) ? row['cells'] as List : const [];
            return Container(
              color: ri.isOdd ? _rowAlt : Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 7.h),
              child: Row(
                children: List.generate(columns.length, (ci) {
                  final cell = (ci < cells.length && cells[ci] is Map) ? cells[ci] as Map : const {};
                  final col = columns[ci] is Map ? columns[ci] as Map : const {};
                  final color = _parseColor(cell['color']) ?? _textColor;
                  final bold = cell['bold'] == true;
                  return Expanded(
                    flex: flexes[ci],
                    child: Text(
                      (cell['text'] ?? '').toString(),
                      textAlign: _align(col['align']),
                      style: TextStyle(
                          color: color,
                          fontSize: 12.sp,
                          fontWeight: bold ? FontWeight.bold : FontWeight.normal),
                    ),
                  );
                }),
              ),
            );
          }),
          if (summary.isNotEmpty)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFFBFBFD),
                border: Border(top: BorderSide(color: _border)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(summary.length, (i) {
                  final s = summary[i] is Map ? summary[i] as Map : const {};
                  final color = _parseColor(s['color']) ?? _textColor;
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text((s['label'] ?? '').toString(),
                            style: TextStyle(color: _subColor, fontSize: 12.sp)),
                        Text((s['value'] ?? '').toString(),
                            style: TextStyle(color: color, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      child: Center(child: card),
    );
  }

  static TextAlign _align(dynamic a) {
    switch (a) {
      case 'right':
        return TextAlign.right;
      case 'center':
        return TextAlign.center;
      default:
        return TextAlign.left;
    }
  }

  /// 解析 "#RRGGBB" 或 "#AARRGGBB" 颜色；非法返回 null。
  static Color? _parseColor(dynamic v) {
    if (v is! String) return null;
    var s = v.trim();
    if (s.isEmpty) return null;
    if (s.startsWith('#')) s = s.substring(1);
    if (s.length == 6) s = 'FF$s';
    if (s.length != 8) return null;
    final n = int.tryParse(s, radix: 16);
    return n == null ? null : Color(n);
  }
}
