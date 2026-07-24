import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../pages/chat/lottery/lottery_trend_service.dart';

/// 群聊里悬浮在群名下方的「单双大路图」走势图面板。
/// - 打开/展开时自动滚到最右（最新一期），最右保留 1 个空列（下一期占位）。
/// - 顶部显示最新期号、结果与「距开奖」倒计时（澳门幸运5 固定 180 秒一期）。
/// - 大路图规则同参考项目：同方向向下堆(每列最多 6 行)、换方向另起一列，只显示最近若干列。
/// - 支持最小化（只留一条细条）/ 展开（显示整张大路图）。
class LotteryTrendView extends StatefulWidget {
  const LotteryTrendView({
    super.key,
    required this.draws,
    this.loading = false,
    this.onRefresh,
  });

  final List<LotteryDraw> draws;
  final bool loading;
  final VoidCallback? onRefresh;

  @override
  State<LotteryTrendView> createState() => _LotteryTrendViewState();
}

class _LotteryTrendViewState extends State<LotteryTrendView> {
  bool _expanded = true;
  final ScrollController _scrollCtrl = ScrollController();
  Timer? _ticker;
  DateTime _now = DateTime.now();
  DateTime _lastPollAt = DateTime.fromMillisecondsSinceEpoch(0);

  static const _danColor = Color(0xFFD62828); // 单 红
  static const _shuangColor = Color(0xFF2846D2); // 双 蓝
  static const _titleColor = Color(0xFF0C1C33);
  static const _subColor = Color(0xFF8E9AB0);
  static const _gridColor = Color(0xFF8C949E); // 大路图格线：对齐牛牛出图 COL_GRID(140,148,158)

  static const double _cell = 22.0;
  static const int _maxRows = 6; // 大路每列最多 6 行（标准）
  static const int _maxDataCols = 19; // 最多显示最近 19 列数据（+1 空尾列 = 20，同参考）
  static const int _drawIntervalSec = 180; // 澳门幸运5 固定 180 秒一期

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
      // 已过开奖时刻但新一期还没到（仍卡在"开奖中"）：每 3 秒主动拉一次，
      // 直到新一期到达（_nextDrawAt 前移、不再 isAfter），避免一直卡"开奖中"等 30s。
      final next = _nextDrawAt;
      if (next != null && _now.isAfter(next) && _now.difference(_lastPollAt).inSeconds >= 3) {
        _lastPollAt = _now;
        widget.onRefresh?.call();
      }
    });
    _scrollToEnd();
  }

  @override
  void didUpdateWidget(covariant LotteryTrendView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scrollToEnd();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  LotteryDraw? get _latest => widget.draws.isNotEmpty ? widget.draws.first : null;

  /// 下一期开奖时间 = 最新一期开奖时间 + 180s。
  DateTime? get _nextDrawAt {
    final t = _latest?.drawTime;
    if (t == null || t.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(t.trim().replaceAll(' ', 'T'));
    if (parsed == null) return null;
    return parsed.add(const Duration(seconds: _drawIntervalSec));
  }

  /// 倒计时文案：m:ss / 开奖中 / 空。
  String get _countdownText {
    final next = _nextDrawAt;
    if (next == null) return '';
    var secs = next.difference(_now).inSeconds;
    if (secs <= 0) return '开奖中';
    if (secs > _drawIntervalSec) secs = _drawIntervalSec; // 防时钟偏差
    final m = secs ~/ 60;
    final s = secs % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _expanded ? _buildExpanded() : _buildCollapsed(),
    );
  }

  Widget _buildCollapsed() {
    final latest = _latest;
    final cd = _countdownText;
    return InkWell(
      onTap: () {
        setState(() => _expanded = true);
        _scrollToEnd();
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          children: [
            Icon(Icons.show_chart, size: 16.w, color: _shuangColor),
            8.horizontalSpace,
            Text('走势图',
                style: TextStyle(fontSize: 13.sp, color: _titleColor, fontWeight: FontWeight.w500)),
            10.horizontalSpace,
            if (latest != null) ...[
              Text('第${latest.issue}期',
                  style: TextStyle(fontSize: 12.sp, color: _subColor)),
              6.horizontalSpace,
              _dot(latest.isDan, 18.w),
              if (cd.isNotEmpty) ...[
                8.horizontalSpace,
                Text(cd == '开奖中' ? cd : '距开奖 $cd',
                    style: TextStyle(fontSize: 11.sp, color: _danColor)),
              ],
            ] else
              Text(widget.loading ? '加载中…' : '暂无数据',
                  style: TextStyle(fontSize: 12.sp, color: _subColor)),
            const Spacer(),
            Icon(Icons.keyboard_arrow_down, size: 20.w, color: _subColor),
          ],
        ),
      ),
    );
  }

  Widget _buildExpanded() {
    final latest = _latest;
    final cd = _countdownText;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(12.w, 8.h, 8.w, 4.h),
          child: Row(
            children: [
              Icon(Icons.show_chart, size: 16.w, color: _shuangColor),
              6.horizontalSpace,
              Text('澳门幸运5 · 走势图',
                  style: TextStyle(fontSize: 13.sp, color: _titleColor, fontWeight: FontWeight.w500)),
              const Spacer(),
              if (latest != null) ...[
                if (cd.isNotEmpty) ...[
                  Icon(Icons.timer_outlined, size: 13.w, color: _danColor),
                  2.horizontalSpace,
                  Text(cd,
                      style: TextStyle(fontSize: 12.sp, color: _danColor, fontWeight: FontWeight.w600)),
                  8.horizontalSpace,
                ],
                Text('第${latest.issue}期 ',
                    style: TextStyle(fontSize: 12.sp, color: _subColor)),
                Text(latest.directionLabel,
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: latest.isDan ? _danColor : _shuangColor,
                        fontWeight: FontWeight.bold)),
                8.horizontalSpace,
              ],
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => widget.onRefresh?.call(),
                child: Icon(Icons.refresh, size: 18.w, color: _subColor),
              ),
              10.horizontalSpace,
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _expanded = false),
                child: Icon(Icons.keyboard_arrow_up, size: 20.w, color: _subColor),
              ),
            ],
          ),
        ),
        Container(height: 1, color: const Color(0xFFEEF0F3)),
        _buildGrid(),
      ],
    );
  }

  Widget _buildGrid() {
    if (widget.draws.isEmpty) {
      return Container(
        height: 56.h,
        alignment: Alignment.center,
        child: Text(
          widget.loading ? '加载中…' : '暂无开奖数据（请确认管理后台已配置数据源）',
          style: TextStyle(fontSize: 12.sp, color: _subColor),
        ),
      );
    }
    final cols = _buildColumns();
    final totalCols = cols.length + 1; // 最右留 1 个空列
    final width = totalCols * _cell;
    final height = _maxRows * _cell;
    return SingleChildScrollView(
      controller: _scrollCtrl,
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _BigRoadPainter(
            cols: cols,
            totalCols: totalCols,
            rows: _maxRows,
            cell: _cell,
            danColor: _danColor,
            shuangColor: _shuangColor,
            gridColor: _gridColor,
          ),
        ),
      ),
    );
  }

  /// 大路图排布：同方向向下堆(每列 ≤ _maxRows)、换方向另起一列；只保留最近 _maxDataCols 列。
  List<List<bool>> _buildColumns() {
    final seq = widget.draws.reversed.map((d) => d.isDan).toList(); // oldest→newest
    final cols = <List<bool>>[];
    for (final isDan in seq) {
      if (cols.isNotEmpty && cols.last.first == isDan && cols.last.length < _maxRows) {
        cols.last.add(isDan);
      } else {
        cols.add([isDan]);
      }
    }
    if (cols.length > _maxDataCols) {
      return cols.sublist(cols.length - _maxDataCols);
    }
    return cols;
  }

  Widget _dot(bool isDan, double size) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDan ? _danColor : _shuangColor,
        shape: BoxShape.circle,
      ),
      child: Text(isDan ? '单' : '双',
          style: TextStyle(fontSize: size * 0.5, color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}

class _BigRoadPainter extends CustomPainter {
  _BigRoadPainter({
    required this.cols,
    required this.totalCols,
    required this.rows,
    required this.cell,
    required this.danColor,
    required this.shuangColor,
    required this.gridColor,
  });

  final List<List<bool>> cols;
  final int totalCols;
  final int rows;
  final double cell;
  final Color danColor;
  final Color shuangColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0; // 细线，对齐牛牛出图(1px)
    // 网格：totalCols 列（含最右空列）× rows 行
    for (int c = 0; c <= totalCols; c++) {
      final x = c * cell;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (int r = 0; r <= rows; r++) {
      final y = r * cell;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    // 只填充数据列，最右空列留白。单双用「彩色文字」（单=红 双=蓝，白底方格），
    // 与之前软件生成的图一致：字带颜色，而非背景色块。
    for (int ci = 0; ci < cols.length; ci++) {
      final col = cols[ci];
      for (int ri = 0; ri < col.length; ri++) {
        final isDan = col[ri];
        final cx = ci * cell + cell / 2;
        final cy = ri * cell + cell / 2;
        _drawText(canvas, isDan ? '单' : '双', Offset(cx, cy), cell * 0.65, isDan ? danColor : shuangColor);
      }
    }
  }

  void _drawText(Canvas canvas, String text, Offset center, double fontSize, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _BigRoadPainter oldDelegate) => true;
}
