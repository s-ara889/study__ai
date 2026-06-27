import 'package:flutter/material.dart';
import 'package:study_ai/widgets/feature_card.dart';
import 'package:study_ai/screens/chat_screen.dart';
import 'package:study_ai/logic/chat_mode.dart';

class HomeScreen extends StatelessWidget {
  final String userName;

  const HomeScreen({
    super.key,
    required this.userName,
  });

  void openChat(
      BuildContext context,
      ChatMode mode,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          mode: mode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24),

                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        TextSpan(
                          text: "Study",
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: "AI",
                          style: TextStyle(color: Color(0xFF8B5CF6)),
                        ),
                      ],
                    ),
                  ),


                ],
              ),

              const SizedBox(height: 20),

              Text(
                "Hello, $userName 👋",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "What do you want to learn today?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // START CHAT BUTTON (ONLY INPUT REPLACEMENT)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06B6D4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    openChat(context, ChatMode.tutor);
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text(
                    "Start Chat",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Explore StudyAI",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    GestureDetector(
                      onTap: () => openChat(context, ChatMode.tutor),
                      child: const FeatureCard(
                        title: "Explain Topic",
                        icon: Icons.school,
                      ),
                    ),

                    GestureDetector(
                      onTap: () => openChat(context, ChatMode.summary),
                      child: const FeatureCard(
                        title: "Summarize Notes",
                        icon: Icons.summarize,
                      ),
                    ),

                    GestureDetector(
                      onTap: () => openChat(context, ChatMode.quiz),
                      child: const FeatureCard(
                        title: "Generate Quiz",
                        icon: Icons.quiz,
                      ),
                    ),

                    GestureDetector(
                      onTap: () => openChat(context, ChatMode.flashcards),
                      child: const FeatureCard(
                        title: "Flashcards",
                        icon: Icons.style,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}