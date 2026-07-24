import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'select_circle_logic.dart';

class SelectCirclePage extends StatelessWidget {
  SelectCirclePage({super.key});

  final logic = Get.find<SelectCircleLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: '选择圈子'),
      body: Column(
        children: [
          _searchBar,
          Expanded(
            child: Obx(() {
              if (logic.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (logic.circles.isEmpty) {
                return Center(
                  child: '暂无圈子'.toText..style = Styles.ts_8E9AB0_14sp,
                );
              }
              return ListView.separated(
                itemCount: logic.circles.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: Styles.c_E8EAEF),
                itemBuilder: (_, index) {
                  final item = logic.circles[index];
                  return ListTile(
                    leading: AvatarView(
                      width: 44.w,
                      height: 44.h,
                      url: item.avatar ?? item.coverUrl,
                      text: item.circleName,
                    ),
                    title: (item.circleName ?? '').toText..style = Styles.ts_0C1C33_16sp,
                    subtitle: (item.description ?? '').toText
                      ..style = Styles.ts_8E9AB0_12sp
                      ..maxLines = 1
                      ..overflow = TextOverflow.ellipsis,
                    onTap: () => logic.select(item),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget get _searchBar => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: TextField(
          controller: logic.searchCtrl,
          textInputAction: TextInputAction.search,
          onChanged: (_) => logic.search(),
          onSubmitted: (_) => logic.search(),
          decoration: InputDecoration(
            hintText: '搜索圈子',
            hintStyle: Styles.ts_8E9AB0_14sp,
            prefixIcon: Icon(Icons.search, color: Styles.c_8E9AB0, size: 20.w),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8.h),
            filled: true,
            fillColor: Styles.c_F8F9FA,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      );
}

