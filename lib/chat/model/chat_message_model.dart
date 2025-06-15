class ChatMessageModel {
  final String id;
  final Role role; // 'user' or 'ai'
  final String content;
  final DateTime timestamp;

  ChatMessageModel({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  ChatMessageModel copyWith({String? content}) {
    return ChatMessageModel(
      id: id,
      role: role,
      content: content ?? this.content,
      timestamp: timestamp,
    );
  }
}

enum Role { user, ai }
