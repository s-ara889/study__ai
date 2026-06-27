import 'package:flutter/material.dart';
import 'package:study_ai/models/conversation.dart';
import 'package:study_ai/services/firestore_service.dart';
import 'package:study_ai/widgets/history_item.dart';
import 'package:study_ai/widgets/search_bar.dart';
import 'package:study_ai/widgets/stat_card.dart';
import 'package:study_ai/screens/chat_screen.dart';
import 'package:study_ai/logic/chat_mode.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Conversation> conversations = [];
  bool loading = true;
  final TextEditingController
  searchController =
      TextEditingController();
  List<Conversation>
  filteredConversations = [];

  @override
  void initState() {
    super.initState();
    loadConversations();
  }
  void searchChats(String query) {
    final results = conversations.where((chat) {
      return chat.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredConversations = results;
    });
  }

  Future<void> loadConversations() async {
    setState(() {
      loading = true;
    });

    final data = await FirestoreService.loadConversations();

    if (!mounted) return;

    setState(() {
      conversations = data;
      filteredConversations = data;
      loading = false;
    });
  }

  Future<void> deleteConversation(String id) async {
    await FirestoreService.deleteConversation(id);

    setState(() {
      conversations.removeWhere(
            (conversation) => conversation.id == id,
      );
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Conversation deleted"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1E),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F1E),
        elevation: 0,
        title: const Text(
          "Study History",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadConversations,
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: loading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : ListView(
          children: [
            const SizedBox(height: 10),

            const Text(
              "Study History",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: searchController,
              onChanged: searchChats,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search chats...",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF141932),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),


            const SizedBox(height: 24),

            const SizedBox(height: 24),

            StatCard(
                title: "Total Chats",
                value:
            conversations.length.toString(),
            ),

            const SizedBox(height: 24),

            if (conversations.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(
                  child: Text(
                    "No study history yet",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

            ...filteredConversations.map(
                  (conversation) => Dismissible(
                key: Key(conversation.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (_) {
                  deleteConversation(conversation.id);
                },
                    child: HistoryItem(
                      title: conversation.title,
                      time: conversation.formattedDate,
                      icon: Icons.chat,
                      color: const Color(0xFF8B5CF6),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              mode: ChatMode.tutor,
                              conversationId:
                              conversation.id,
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ),

            const SizedBox(height: 30),

            if (conversations.isNotEmpty)
              const Center(
                child: Text(
                  "END OF HISTORY",
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    letterSpacing: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}