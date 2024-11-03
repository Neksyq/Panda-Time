import 'package:flutter/material.dart';
import 'package:pandatime/widgets/navigation/custom_drawer.dart';

class GrowStats extends StatelessWidget {
  const GrowStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            padding: const EdgeInsets.only(left: 16.0, top: 12.0),
            icon: const Icon(Icons.menu),
            iconSize: 36.0,
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: const CustomDrawer(),
      body: const Center(
        child: Text('Welcome to Growth Stats!'),
      ),
    );
  }
}
