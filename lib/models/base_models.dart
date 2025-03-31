/// Base 是系統的最高層級組織單位
class Base {
  final String id; // 基地唯一識別符
  final String name; // 基地名稱
  final String description; // 基地描述
  final DateTime createdAt; // 創建時間
  final DateTime updatedAt; // 最後更新時間
  final String ownerId; // 創建者ID
  final List<BaseRole> roles; // 自定義角色列表
  final List<BaseMember> members; // 成員列表
  final List<BaseFolderOrBoard> contents; // 基地內容 (文件夾或協作版)

  Base({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.ownerId,
    required this.roles,
    required this.members,
    required this.contents,
  });

  factory Base.fromJson(Map<String, dynamic> json) {
    return Base(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      ownerId: json['ownerId'],
      roles: (json['roles'] as List<dynamic>?)?.map((e) => BaseRole.fromJson(e)).toList() ?? [],
      members: (json['members'] as List<dynamic>?)?.map((e) => BaseMember.fromJson(e)).toList() ?? [],
      contents: (json['contents'] as List<dynamic>?)?.map((e) {
            if (e['type'] == 'folder') {
              return Folder.fromJson(e);
            } else {
              return Board.fromJson(e);
            }
          }).toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'ownerId': ownerId,
      'roles': roles.map((e) => e.toJson()).toList(),
      'members': members.map((e) => e.toJson()).toList(),
      'contents': contents.map((e) => e.toJson()).toList(),
    };
  }
}

/// 基地角色 (RBAC - 基於角色的訪問控制)
class BaseRole {
  final String id; // 角色唯一識別符
  final String name; // 角色名稱
  final String color; // 角色顯示顏色
  final Map<String, bool> permissions; // 權限映射 <權限名稱, 是否啟用>

  BaseRole({
    required this.id,
    required this.name,
    required this.color,
    required this.permissions,
  });

  factory BaseRole.fromJson(Map<String, dynamic> json) {
    return BaseRole(
      id: json['id'],
      name: json['name'],
      color: json['color'] ?? '#FF0000',
      permissions: Map<String, bool>.from(json['permissions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'permissions': permissions,
    };
  }
}

/// 基地成員
class BaseMember {
  final String userId; // 用戶ID
  final List<String> roleIds; // 用戶擁有的角色ID列表
  final DateTime joinedAt; // 加入時間
  final BaseMemberStatus status; // 成員狀態

  BaseMember({
    required this.userId,
    required this.roleIds,
    required this.joinedAt,
    required this.status,
  });

  factory BaseMember.fromJson(Map<String, dynamic> json) {
    return BaseMember(
      userId: json['userId'],
      roleIds: List<String>.from(json['roleIds'] ?? []),
      joinedAt: DateTime.parse(json['joinedAt']),
      status: BaseMemberStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] ?? 'active'),
        orElse: () => BaseMemberStatus.active,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'roleIds': roleIds,
      'joinedAt': joinedAt.toIso8601String(),
      'status': status.toString().split('.').last,
    };
  }
}

/// 成員狀態枚舉
enum BaseMemberStatus {
  active, // 活躍
  inactive, // 非活躍
  invited, // 已邀請未加入
  banned // 已禁止
}

/// 基地權限枚舉
enum BasePermission {
  manageBase, // 管理基地設置
  manageRoles, // 管理角色
  manageMembers, // 管理成員
  createFolder, // 創建文件夾
  createBoard, // 創建協作版
  viewAllContent, // 查看所有內容
  manageAllContent, // 管理所有內容
}

/// 基地內容項 (可以是文件夾或協作版)
abstract class BaseFolderOrBoard {
  String get id; // 唯一識別符
  String get name; // 名稱
  String get description; // 描述
  DateTime get createdAt; // 創建時間
  DateTime get updatedAt; // 最後更新時間
  String get createdBy; // 創建者ID
  String get type; // 類型，用於區分文件夾和協作版

  Map<String, dynamic> toJson();
}

/// 文件夾結構
class Folder implements BaseFolderOrBoard {
  @override
  final String id; // 唯一識別符
  @override
  final String name; // 名稱
  @override
  final String description; // 描述
  @override
  final DateTime createdAt; // 創建時間
  @override
  final DateTime updatedAt; // 最後更新時間
  @override
  final String createdBy; // 創建者ID
  @override
  String get type => 'folder'; // 類型

  final List<BaseFolderOrBoard> contents; // 文件夾內容 (子文件夾或協作版)
  final int level; // 文件夾層級 (最多3層)

  Folder({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.contents,
    required this.level,
  });

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdBy: json['createdBy'],
      level: json['level'] ?? 1,
      contents: (json['contents'] as List<dynamic>?)?.map((e) {
            if (e['type'] == 'folder') {
              return Folder.fromJson(e);
            } else {
              return Board.fromJson(e);
            }
          }).toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'type': 'folder',
      'level': level,
      'contents': contents.map((e) => e.toJson()).toList(),
    };
  }

  // 檢查是否可以添加子文件夾 (層級限制)
  bool canAddSubfolder() {
    return level < 3;
  }
}

/// 協作版
class Board implements BaseFolderOrBoard {
  @override
  final String id; // 唯一識別符
  @override
  final String name; // 名稱
  @override
  final String description; // 描述
  @override
  final DateTime createdAt; // 創建時間
  @override
  final DateTime updatedAt; // 最後更新時間
  @override
  final String createdBy; // 創建者ID
  @override
  String get type => 'board'; // 類型

  final List<BoardMember> members; // 版成員列表
  final List<BoardRole> roles; // 版角色列表

  Board({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.members,
    required this.roles,
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdBy: json['createdBy'],
      members: (json['members'] as List<dynamic>?)?.map((e) => BoardMember.fromJson(e)).toList() ?? [],
      roles: (json['roles'] as List<dynamic>?)?.map((e) => BoardRole.fromJson(e)).toList() ?? [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'type': 'board',
      'members': members.map((e) => e.toJson()).toList(),
      'roles': roles.map((e) => e.toJson()).toList(),
    };
  }
}

/// 協作版角色
class BoardRole {
  final String id; // 角色唯一識別符
  final String name; // 角色名稱
  final String color; // 角色顯示顏色
  final Map<String, bool> permissions; // 權限映射 <權限名稱, 是否啟用>

  BoardRole({
    required this.id,
    required this.name,
    required this.color,
    required this.permissions,
  });

  factory BoardRole.fromJson(Map<String, dynamic> json) {
    return BoardRole(
      id: json['id'],
      name: json['name'],
      color: json['color'] ?? '#FF0000',
      permissions: Map<String, bool>.from(json['permissions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'permissions': permissions,
    };
  }
}

/// 協作版成員
class BoardMember {
  final String userId; // 用戶ID
  final List<String> roleIds; // 用戶擁有的角色ID列表
  final DateTime joinedAt; // 加入時間

  BoardMember({
    required this.userId,
    required this.roleIds,
    required this.joinedAt,
  });

  factory BoardMember.fromJson(Map<String, dynamic> json) {
    return BoardMember(
      userId: json['userId'],
      roleIds: List<String>.from(json['roleIds'] ?? []),
      joinedAt: DateTime.parse(json['joinedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'roleIds': roleIds,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }
}

/// 協作版權限枚舉
enum BoardPermission {
  manageBoard, // 管理協作版
  manageRoles, // 管理角色
  manageMembers, // 管理成員
  useChatroom, // 使用聊天室
  manageCalendar, // 管理行事曆
  viewCalendar, // 查看行事曆
  createDatabase, // 創建資料庫
  manageAllDatabases, // 管理所有資料庫
  viewAllDatabases, // 查看所有資料庫
}
