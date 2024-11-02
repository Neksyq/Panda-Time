import 'package:flutter/material.dart';
import 'package:pandatime/widgets/navigation/drawer_menu_item.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Drawer(
        backgroundColor: Colors.grey[900],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/profile_pic.png')),
                  const SizedBox(height: 16),
                  const Text('Panda User',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Level 10 • 5000 XP',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                ],
              ),
            ),
            Expanded(
                child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: const [
                DrawerMenuItem(icon: Icons.home, label: 'Home'),
                DrawerMenuItem(icon: Icons.show_chart, label: 'Progress'),
                DrawerMenuItem(icon: Icons.settings, label: 'Settings'),
                DrawerMenuItem(icon: Icons.logout, label: 'Logout'),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
