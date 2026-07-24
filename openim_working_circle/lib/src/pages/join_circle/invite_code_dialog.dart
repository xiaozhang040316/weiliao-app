import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

class InviteCodeDialog extends StatefulWidget {
  final int count;

  const InviteCodeDialog({
    Key? key,
    required this.count,
  }) : super(key: key);

  @override
  State<InviteCodeDialog> createState() => _InviteCodeDialogState();
}

class _InviteCodeDialogState extends State<InviteCodeDialog> {
  late final List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(widget.count, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: EdgeInsets.all(16.w),
        constraints: BoxConstraints(maxWidth: 300.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            '请输入邀请码'.toText..style = Styles.ts_0C1C33_16sp_medium,
            12.verticalSpace,
            ...List.generate(widget.count, (index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: TextField(
                  controller: controllers[index],
                  decoration: InputDecoration(
                    hintText: '邀请码 ${index + 1}',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
              );
            }),
            16.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(result: null),
                  child: const Text('取消'),
                ),
                8.horizontalSpace,
                TextButton(
                  onPressed: () {
                    final codes = controllers
                        .map((c) => c.text.trim().toUpperCase())
                        .where((code) => code.isNotEmpty)
                        .toList();
                    if (codes.length == widget.count) {
                      Get.back(result: codes);
                    } else {
                      IMViews.showToast('请填写完整的邀请码');
                    }
                  },
                  child: const Text('确定'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

