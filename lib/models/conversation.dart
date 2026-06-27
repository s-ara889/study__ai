class Conversation {
  final String id;
  final String title;
  final int createdAt;

  Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
  });

  factory Conversation.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    return Conversation(
      id: id,
      title: map['title'] ?? 'Untitled Chat',
      createdAt: map['createdAt'] ?? 0,
    );
  }

  String get formattedDate {
    final date = DateTime.fromMillisecondsSinceEpoch(createdAt);

    return "${date.day}/${date.month}/${date.year}";
  }
}