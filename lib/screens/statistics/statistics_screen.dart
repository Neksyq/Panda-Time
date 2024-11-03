import 'package:flutter/material.dart';

class GrowStats extends StatelessWidget {
  const GrowStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Growth Stats'),
      ),
      body: const Center(
        child: Text('Welcome to Growth Stats!'),
      ),
    );
  }
}
