class AiChatResponseModel {
  final bool success;
  final String reply;
  final int aiContextId;

  const AiChatResponseModel({
    required this.success,
    required this.reply,
    required this.aiContextId,
  });

  factory AiChatResponseModel.fromJson(Map<String, dynamic> json) {
    return AiChatResponseModel(
      success: json['success'] == true,
      reply: json['reply']?.toString() ?? '',
      aiContextId: json['ai_context_id'] is int
          ? json['ai_context_id'] as int
          : int.tryParse(json['ai_context_id']?.toString() ?? '') ?? 0,
    );
  }
}