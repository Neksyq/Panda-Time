import 'package:flutter/material.dart';
import 'package:pandatime/widgets/navigation/drawer_menu_item.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DrawerHeader(
              child: Column(
                children: [
                  const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/profile_pic.png')),
                  const SizedBox(height: 16),
                  Text('Panda User',
                      style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Level 10 • 5000 XP',
                      style: TextStyle(color: Colors.grey[800], fontSize: 14)),
                ],
              ),
            ),
            Expanded(
                child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                DrawerMenuItem(
                  icon: Icons.home,
                  label: 'Panda Home',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/panda_home');
                  },
                ),
                DrawerMenuItem(
                    icon: Icons.show_chart,
                    label: 'Statistics',
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      Navigator.pushReplacementNamed(context, '/growth_stats');
                    }),
                DrawerMenuItem(
                  icon: Icons.show_chart,
                  label: 'Achievements & Challenges',
                  onTap: () {},
                ),
                DrawerMenuItem(
                  icon: Icons.show_chart,
                  label: 'Bamboo shop',
                  onTap: () {},
                ),
                DrawerMenuItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  onTap: () {},
                ),
                DrawerMenuItem(
                  icon: Icons.logout,
                  label: 'Logout',
                  onTap: () async {
                    await _signOutFromGoogle();
                  },
                ),
              ],
            ))
          ],
        ),
      ),
    );
  }

  Future<bool> _signOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }
}
