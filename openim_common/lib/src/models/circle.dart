class CircleInfo {
  CircleInfo({
    this.circleID,
    this.circleName,
    this.description,
    this.avatar,
    this.coverUrl,
    this.ownerUserID,
    this.memberCount,
    this.status,
    this.createTime,
    this.updateTime,
    this.visibility,
    this.canInvite,
    this.inviteCodeNum,
  });

  String? circleID;
  String? circleName;
  String? description;
  String? avatar;
  String? coverUrl;
  String? ownerUserID;
  int? memberCount;
  int? status;
  int? createTime;
  int? updateTime;
  int? visibility;
  bool? canInvite;
  int? inviteCodeNum;

  CircleInfo.fromJson(Map<String, dynamic> json) {
    circleID = json['circleID'];
    circleName = json['circleName'];
    description = json['description'];
    avatar = json['avatar'];
    coverUrl = json['coverUrl'] ?? json['coverURL'];
    ownerUserID = json['ownerUserID'];
    memberCount = json['memberCount'];
    status = json['status'];
    createTime = json['createTime'];
    updateTime = json['updateTime'];
    visibility = json['visibility'];
    canInvite = json['canInvite'] == true;
    inviteCodeNum = json['inviteCodeNum'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['circleID'] = circleID;
    data['circleName'] = circleName;
    data['description'] = description;
    data['avatar'] = avatar;
    data['coverUrl'] = coverUrl;
    data['ownerUserID'] = ownerUserID;
    data['memberCount'] = memberCount;
    data['status'] = status;
    data['createTime'] = createTime;
    data['updateTime'] = updateTime;
    data['visibility'] = visibility;
    data['canInvite'] = canInvite;
    data['inviteCodeNum'] = inviteCodeNum;
    return data;
  }
}

class CircleMember {
  CircleMember({
    this.userID,
    this.nickname,
    this.faceURL,
    this.isAdmin = false,
    this.isBanned = false,
    this.status,
    this.joinTime,
  });

  String? userID;
  String? nickname;
  String? faceURL;
  bool isAdmin;
  bool isBanned;
  int? status;
  int? joinTime;

  CircleMember.fromJson(Map<String, dynamic> json)
      : isAdmin = json['isAdmin'] == true,
        isBanned = json['isBanned'] == true {
    final userMap = json['user'];
    final userNickname =
        userMap is Map<String, dynamic> ? userMap['nickname'] as String? : null;
    final userFaceURL =
        userMap is Map<String, dynamic> ? userMap['faceURL'] as String? : null;

    userID = json['userID'] ?? (userMap is Map<String, dynamic> ? userMap['userID'] : null);
    nickname = json['nickname'] ?? userNickname ?? json['name'] ?? json['userName'];
    faceURL = json['faceURL'] ?? userFaceURL;
    status = json['status'];
    joinTime = json['joinTime'];
  }

  Map<String, dynamic> toJson() => {
        'userID': userID,
        'nickname': nickname,
        'faceURL': faceURL,
        'isAdmin': isAdmin,
        'isBanned': isBanned,
        'status': status,
        'joinTime': joinTime,
      };
}

