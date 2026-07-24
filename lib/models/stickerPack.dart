/// 表情包数据模型
class StickerPack {
  /// 表情包ID
  final String id;
  
  /// 表情包名称（英文）
  final String name;
  
  /// 表情包显示名称（中文）
  final String displayName;
  
  /// 封面图片路径
  final String coverPath;
  
  /// 表情包描述
  final String? description;
  
  /// 表情列表
  final List<StickerItem> stickers;
  
  /// 是否为默认表情包
  final bool isDefault;
  
  /// 创建时间
  final DateTime createTime;

  const StickerPack({
    required this.id,
    required this.name,
    required this.displayName,
    required this.coverPath,
    required this.stickers,
    this.description,
    this.isDefault = false,
    required this.createTime,
  });

  factory StickerPack.fromJson(Map<String, dynamic> json) {
    return StickerPack(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      coverPath: json['coverPath'] as String,
      description: json['description'] as String?,
      stickers: (json['stickers'] as List<dynamic>)
          .map((item) => StickerItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      isDefault: json['isDefault'] as bool? ?? false,
      createTime: DateTime.fromMillisecondsSinceEpoch(json['createTime'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'coverPath': coverPath,
      'description': description,
      'stickers': stickers.map((item) => item.toJson()).toList(),
      'isDefault': isDefault,
      'createTime': createTime.millisecondsSinceEpoch,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StickerPack && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'StickerPack(id: $id, name: $name, displayName: $displayName, stickers: ${stickers.length})';
  }
}

/// 单个表情贴纸数据模型
class StickerItem {
  /// 表情ID
  final String id;
  
  /// 文件名
  final String fileName;
  
  /// 资源路径
  final String assetPath;
  
  /// 表情宽度
  final int width;
  
  /// 表情高度
  final int height;
  
  /// 是否为动态表情
  final bool isAnimated;
  
  /// 表情标签
  final List<String>? tags;
  
  /// 表情描述
  final String? description;

  const StickerItem({
    required this.id,
    required this.fileName,
    required this.assetPath,
    required this.width,
    required this.height,
    this.isAnimated = true,
    this.tags,
    this.description,
  });

  factory StickerItem.fromJson(Map<String, dynamic> json) {
    return StickerItem(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      assetPath: json['assetPath'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
      isAnimated: json['isAnimated'] as bool? ?? true,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'assetPath': assetPath,
      'width': width,
      'height': height,
      'isAnimated': isAnimated,
      'tags': tags,
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StickerItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'StickerItem(id: $id, fileName: $fileName, isAnimated: $isAnimated)';
  }
}

/// 表情包配置
class StickerConfig {
  /// 配置版本
  final String version;
  
  /// 表情包列表
  final List<StickerPack> packs;
  
  /// 默认表情包ID
  final String? defaultPackId;
  
  /// 最后更新时间
  final DateTime lastUpdated;

  const StickerConfig({
    required this.version,
    required this.packs,
    this.defaultPackId,
    required this.lastUpdated,
  });

  factory StickerConfig.fromJson(Map<String, dynamic> json) {
    return StickerConfig(
      version: json['version'] as String,
      packs: (json['packs'] as List<dynamic>)
          .map((item) => StickerPack.fromJson(item as Map<String, dynamic>))
          .toList(),
      defaultPackId: json['defaultPackId'] as String?,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(json['lastUpdated'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'packs': packs.map((pack) => pack.toJson()).toList(),
      'defaultPackId': defaultPackId,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  /// 根据ID获取表情包
  StickerPack? getPackById(String id) {
    try {
      return packs.firstWhere((pack) => pack.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 获取默认表情包
  StickerPack? get defaultPack {
    if (defaultPackId != null) {
      return getPackById(defaultPackId!);
    }
    return packs.isNotEmpty ? packs.first : null;
  }

  @override
  String toString() {
    return 'StickerConfig(version: $version, packs: ${packs.length})';
  }
}
