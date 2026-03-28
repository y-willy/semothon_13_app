class ChatMessageModel {
  final int id;
  final String sender;
  final String time;
  final String message;
  final String? roleTag;
  final bool isAi;
  final bool isFile;
  final bool isRead;

  const ChatMessageModel({
    required this.id,
    required this.sender,
    required this.time,
    required this.message,
    this.roleTag,
    required this.isAi,
    required this.isFile,
    required this.isRead,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as int,
      sender: json['sender'] as String,
      time: json['time'] as String,
      message: json['message'] as String,
      roleTag: json['roleTag'] as String?,
      isAi: json['isAi'] as bool,
      isFile: json['isFile'] as bool,
      isRead: json['isRead'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'time': time,
      'message': message,
      'roleTag': roleTag,
      'isAi': isAi,
      'isFile': isFile,
      'isRead': isRead,
    };
  }

  ChatMessageModel copyWith({
    int? id,
    String? sender,
    String? time,
    String? message,
    String? roleTag,
    bool? isAi,
    bool? isFile,
    bool? isRead,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      time: time ?? this.time,
      message: message ?? this.message,
      roleTag: roleTag ?? this.roleTag,
      isAi: isAi ?? this.isAi,
      isFile: isFile ?? this.isFile,
      isRead: isRead ?? this.isRead,
    );
  }
}
