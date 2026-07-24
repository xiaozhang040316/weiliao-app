import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'create_circle_logic.dart';

class CreateCirclePage extends StatelessWidget {
  CreateCirclePage({super.key});

  final logic = Get.find<CreateCircleLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.c_F8F9FA,
      appBar: TitleBar.back(title: logic.isEdit ? '编辑圈子' : '创建圈子'),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('圈子名称'),
              8.verticalSpace,
              _input(
                hint: '请输入4-10个字符',
                controller: logic.nameCtrl,
                maxLength: 10,
              ),
              16.verticalSpace,
              _label('圈子简介'),
              8.verticalSpace,
              _multilineInput(
                hint: '圈子内容描述',
                controller: logic.descCtrl,
                maxLength: 500,
              ),
              20.verticalSpace,
              _coverPicker,
              16.verticalSpace,
              _circleTypeSelector,
              16.verticalSpace,
              _inviteSelector,
              16.verticalSpace,
              _label('需要邀请码数量'),
              8.verticalSpace,
              _inviteCodeNumSelector,
              40.verticalSpace,
              SizedBox(
                width: double.infinity,
                child: Button(
                  text: logic.isEdit ? '保存' : '提交',
                  height: 48.h,
                  onTap: logic.submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Row(
        children: [
          Container(
            width: 6.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: const Color(0xFF3B7CFF),
              shape: BoxShape.circle,
            ),
          ),
          8.horizontalSpace,
          text.toText..style = Styles.ts_0C1C33_16sp_medium,
        ],
      );

  Widget _input({
    required String hint,
    required TextEditingController controller,
    int maxLength = 20,
    bool isNumber = false,
  }) =>
      Container(
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: TextField(
            controller: controller,
            maxLength: maxLength,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              counterText: '',
              border: InputBorder.none,
            ),
          ),
        ),
      );

  Widget _multilineInput({
    required String hint,
    required TextEditingController controller,
    int maxLength = 500,
  }) =>
      Container(
        height: 180.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: TextField(
          controller: controller,
          maxLines: null,
          expands: true,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            border: InputBorder.none,
          ),
        ),
      );

  Widget get _coverPicker => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          '我的封面'.toText..style = Styles.ts_0C1C33_16sp,
          GestureDetector(
            onTap: logic.pickCover,
            child: Container(
              width: 64.w,
              height: 64.h,
              decoration: BoxDecoration(
                color: Styles.c_F8F9FA,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Styles.c_E8EAEF),
              ),
              child: Obx(() {
                final asset = logic.cover.value;
                final url = logic.existingAvatar.value;
                if (asset != null) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: AssetEntityImage(
                      asset,
                      isOriginal: false,
                      fit: BoxFit.cover,
                    ),
                  );
                }
                if (url.isNotEmpty) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.image_not_supported_outlined,
                        size: 24.w,
                        color: Styles.c_8E9AB0,
                      ),
                    ),
                  );
                }
                return Icon(Icons.camera_alt_outlined, size: 24.w, color: Styles.c_8E9AB0);
              }),
            ),
          ),
        ],
      );

  Widget get _circleTypeSelector => Obx(
        () => Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              '圈子类型'.toText..style = Styles.ts_0C1C33_16sp,
              Row(
                children: [
                  _radioItem(
                    label: '私密圈',
                    checked: logic.circleType.value == 0,
                    onTap: () => logic.switchType(0),
                  ),
                  16.horizontalSpace,
                  _radioItem(
                    label: '公开圈',
                    checked: logic.circleType.value == 1,
                    onTap: () => logic.switchType(1),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget get _inviteSelector => Obx(
        () => Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              '允许成员邀请'.toText..style = Styles.ts_0C1C33_16sp,
              Row(
                children: [
                  _radioItem(
                    label: '不允许',
                    checked: !logic.canInvite.value,
                    onTap: () => logic.canInvite.value = false,
                  ),
                  16.horizontalSpace,
                  _radioItem(
                    label: '允许',
                    checked: logic.canInvite.value,
                    onTap: () => logic.canInvite.value = true,
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _radioItem({
    required String label,
    required bool checked,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            checked ? Icons.radio_button_checked : Icons.radio_button_off,
            color: Styles.c_0089FF,
            size: 20.w,
          ),
          4.horizontalSpace,
          label.toText..style = Styles.ts_0C1C33_14sp,
        ],
      ),
    );
  }

  Widget get _inviteCodeNumSelector => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            '需要邀请码数量'.toText..style = Styles.ts_0C1C33_16sp,
            Obx(() {
              final value = logic.inviteCodeNum.value;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: value > 0 ? () => logic.decreaseInviteCodeNum() : null,
                    child: Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: value > 0 ? Styles.c_0089FF : Styles.c_E8EAEF,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.remove,
                        color: value > 0 ? Colors.white : Styles.c_8E9AB0,
                        size: 20.w,
                      ),
                    ),
                  ),
                  20.horizontalSpace,
                  Container(
                    width: 60.w,
                    alignment: Alignment.center,
                    child: value.toString().toText..style = Styles.ts_0C1C33_18sp_medium,
                  ),
                  20.horizontalSpace,
                  GestureDetector(
                    onTap: value < 10 ? () => logic.increaseInviteCodeNum() : null,
                    child: Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: value < 10 ? Styles.c_0089FF : Styles.c_E8EAEF,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.add,
                        color: value < 10 ? Colors.white : Styles.c_8E9AB0,
                        size: 20.w,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      );
}

