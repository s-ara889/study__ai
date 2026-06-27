class ChatMessage {
  final String text;
  final bool isUser;
  final int timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp,
    };
  }

  factory ChatMessage.fromMap(
      Map<String, dynamic> map,
      ) {
    return ChatMessage(
      text: map['text'] ?? '',
      isUser: map['isUser'] ?? false,
      timestamp: map['timestamp'] ?? 0,
    );
  }
}