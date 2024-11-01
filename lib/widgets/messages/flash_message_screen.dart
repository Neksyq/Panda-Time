import 'package:flutter/material.dart';

class FlashMessage extends StatefulWidget {
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
  _FlashMessageState createState() => _FlashMessageState();
}

class _FlashMessageState extends State<FlashMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // Animation duration
    );

    // Slide from the bottom to the original position
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start position: bottom of the screen
      end: Offset.zero, // End position: normal
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward(); // Start the slide animation
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: const Key('flash_message'),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        ScaffoldMessenger.of(context).clearSnackBars();
      },
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 90,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.message,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
      duration: const Duration(seconds: 5),
    ),
  );
}
