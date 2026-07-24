import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_working_circle/src/w_apis.dart';

class SelectCircleLogic extends GetxController {
  final searchCtrl = TextEditingController();
  final circles = <CircleInfo>[].obs;
  final allCircles = <CircleInfo>[]; // 保存原始列表
  final loading = false.obs;

  @override
  void onReady() {
    _load();
    super.onReady();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }

  Future<void> _load() async {
    loading.value = true;
    try {
      final list = await WApis.getCircleList(showNumber: 200);
      allCircles.clear();
      allCircles.addAll(list);
      circles.assignAll(list);
    } finally {
      loading.value = false;
    }
  }

  void search() {
    final keyword = searchCtrl.text.trim().toLowerCase();
    if (keyword.isEmpty) {
      circles.assignAll(allCircles);
      return;
    }
    final filtered = allCircles.where((circle) {
      final name = (circle.circleName ?? '').toLowerCase();
      final desc = (circle.description ?? '').toLowerCase();
      return name.contains(keyword) || desc.contains(keyword);
    }).toList();
    circles.assignAll(filtered);
  }

  void select(CircleInfo info) {
    Get.back(result: info);
  }
}

