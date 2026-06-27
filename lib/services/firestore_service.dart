import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_ai/models/chat_message.dart';
import 'package:study_ai/models/conversation.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static String? get uid =>
      FirebaseAuth.instance.currentUser?.uid;
  static Future<Map<String, int>> getUserStats() async {
    if (uid == null) return {};

    final conversationsSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .get();

    int totalMessages = 0;

    for (var convo in conversationsSnapshot.docs) {
      final messagesSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('conversations')
          .doc(convo.id)
          .collection('messages')
          .get();

      totalMessages += messagesSnapshot.docs.length;
    }

    return {
      "chats": conversationsSnapshot.docs.length,
      "messages": totalMessages,
    };
  }

  // CREATE NEW CONVERSATION

  static Future<String> createConversation(
      String title) async {
    if (uid == null) return '';

    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .add({
      'title': title,
      'createdAt':
      DateTime.now().millisecondsSinceEpoch,
    });

    return doc.id;
  }

  // SAVE MESSAGE

  static Future<void> saveMessage(
      String conversationId,
      ChatMessage message,
      ) async {
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .add(
      message.toMap(),
    );
  }

  // LOAD MESSAGES

  static Future<List<ChatMessage>>
  loadMessages(
      String conversationId,
      ) async {
    if (uid == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp')
        .get();

    return snapshot.docs
        .map(
          (e) => ChatMessage.fromMap(
        e.data(),
      ),
    )
        .toList();
  }

  // LOAD CONVERSATIONS

  static Future<List<Conversation>>
  loadConversations() async {
    if (uid == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .orderBy(
      'createdAt',
      descending: true,
    )
        .get();

    return snapshot.docs
        .map(
          (doc) => Conversation.fromMap(
        doc.id,
        doc.data(),
      ),
    )
        .toList();
  }

  // DELETE CONVERSATION

  static Future<void> deleteConversation(
      String conversationId) async {
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .doc(conversationId)
        .delete();
  }
}
