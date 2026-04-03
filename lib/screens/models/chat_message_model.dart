class ChatMessageModel {
  final int id;
  final String sender;
  final String message;
  final String time;
  final bool isMe;
  final bool isRead;
  final bool isAi;
  final bool isFile;
  final String roleTag;

  const ChatMessageModel({
    required this.id,
    required this.sender,
    required this.message,
    required this.time,
    this.isMe = false,
    this.isRead = false,
    this.isAi = false,
    this.isFile = false,
    this.roleTag = '',
  });

  factory ChatMessageModel.fromJson(
      Map<String, dynamic> json,
      int currentUserId,
      ) {
    final senderUserId = _toInt(json['sender_user_id']);
    final senderName = _toString(json['sender_name']);
    final content = _toString(json['content']);
    final createdAtRaw = _toString(json['created_at']);
    final messageType = _toString(json['message_type']).toUpperCase();

    final createdAt = DateTime.tryParse(createdAtRaw)?.toLocal();

    String formattedTime = '';
    if (createdAt != null) {
      final period = createdAt.hour < 12 ? '오전' : '오후';
      final hour = createdAt.hour % 12 == 0 ? 12 : createdAt.hour % 12;
      final minute = createdAt.minute.toString().padLeft(2, '0');
      formattedTime = '$period $hour:$minute';
    }

    return ChatMessageModel(
      id: _toInt(json['id']),
      sender: senderName,
      message: content,
      time: formattedTime,
      isMe: senderUserId == currentUserId,
      isRead: true,
      isAi: messageType == 'AI',
      isFile: messageType == 'FILE',
      roleTag: _toString(json['role_tag']),
    );
  }

  ChatMessageModel copyWith({
    int? id,
    String? sender,
    String? message,
    String? time,
    bool? isMe,
    bool? isRead,
    bool? isAi,
    bool? isFile,
    String? roleTag,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      message: message ?? this.message,
      time: time ?? this.time,
      isMe: isMe ?? this.isMe,
      isRead: isRead ?? this.isRead,
      isAi: isAi ?? this.isAi,
      isFile: isFile ?? this.isFile,
      roleTag: roleTag ?? this.roleTag,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'message': message,
      'time': time,
      'isMe': isMe,
      'isRead': isRead,
      'isAi': isAi,
      'isFile': isFile,
      'roleTag': roleTag,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _toString(dynamic value) {
    return value?.toString() ?? '';
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    return value?.toString().toLowerCase() == 'true';
  }
}