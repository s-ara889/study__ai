import 'package:flutter/material.dart';
import 'package:study_ai/screens/home_screen.dart';
import 'package:study_ai/screens/chat_screen.dart';
import 'package:study_ai/screens/history_screen.dart';
import 'package:study_ai/screens/profile_screen.dart';
import 'package:study_ai/logic/chat_mode.dart';

class MainScreen extends StatefulWidget {
  final String userName;
  final String email;

  const MainScreen({
    super.key,
    required this.userName,
    required this.email,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();

    screens = [
      HomeScreen(
        userName: widget.userName,
      ),

      const ChatScreen(
        mode: ChatMode.tutor,
      ),

      const HistoryScreen(),

      ProfileScreen(
        userName: widget.userName,
        email: widget.email,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),

      body: screens[currentIndex],

      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF141932),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF1E2545),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home,
              label: "Home",
              active: currentIndex == 0,
              onTap: () {
                setState(() {
                  currentIndex = 0;
                });
              },
            ),

            _NavItem(
              icon: Icons.chat,
              label: "Chat",
              active: currentIndex == 1,
              onTap: () {
                setState(() {
                  currentIndex = 1;
                });
              },
            ),

            _NavItem(
              icon: Icons.history,
              label: "History",
              active: currentIndex == 2,
              onTap: () {
                setState(() {
                  currentIndex = 2;
                });
              },
            ),

            _NavItem(
              icon: Icons.person,
              label: "Profile",
              active: currentIndex == 3,
              onTap: () {
                setState(() {
                  currentIndex = 3;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF8B5CF6).withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active
                  ? const Color(0xFF8B5CF6)
                  : Colors.grey,
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: active
                    ? const Color(0xFF8B5CF6)
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}