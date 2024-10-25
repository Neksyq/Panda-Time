import 'package:flutter/material.dart';

class FlashMessage extends StatelessWidget {
  final String title;
  final String message;
  final Color backgroundColor;

  const FlashMessage({
    super.key,
    required this.title,
    required this.message,
    this.backgroundColor =
        const Color.fromARGB(255, 20, 218, 149), // Default color
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          height: 90,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 48),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void showFlashMessage(BuildContext context, String title, String message,
    {Color backgroundColor = const Color.fromARGB(255, 20, 218, 149)}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: FlashMessage(
        title: title,
        message: message,
        backgroundColor: backgroundColor,
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration:
          const Duration(days: 365), // Long duration to simulate persistence
    ),
  );
}
