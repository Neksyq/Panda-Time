import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  void toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                _buildPandaLogo(),
                const SizedBox(height: 20),
                _buildTextField(label: 'Email'),
                const SizedBox(height: 20),
                _buildTextField(label: 'Password', obscureText: true),
                if (!isLogin) ...[
                  const SizedBox(height: 20),
                  _buildTextField(label: 'Confirm Password', obscureText: true),
                ],
                const SizedBox(height: 20),
                _buildAuthButton(),
                const SizedBox(height: 20),
                const Text('or', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                _buildGoogleAuthButton(),
                const SizedBox(height: 20),
                _buildToggleAuthMode(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPandaLogo() {
    return Image.asset(
      'assets/images/panda_logo.jpg',
      height: 100,
    );
  }

  Widget _buildTextField({required String label, bool obscureText = false}) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }

  Widget _buildAuthButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          isLogin ? 'Log In' : 'Sign Up',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleAuthButton() {
    if (!isLogin) {
      return ElevatedButton.icon(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[700],
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        icon: Image.asset(
          'assets/images/panda_logo.jpg', // Replace with actual image assets for Google and Apple
          height: 24,
        ),
        label: const Text('Sign up with Google'),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[700],
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        icon: Image.asset(
          'assets/images/panda_logo.jpg', // Replace with actual image assets for Google and Apple
          height: 24,
        ),
        label: const Text('Sign in with Google'),
      );
    }
  }

  Widget _buildToggleAuthMode() {
    return GestureDetector(
      onTap: toggleAuthMode,
      child: Text(
        isLogin
            ? "Don't have an account? Sign Up"
            : "Already have an account? Log In",
        style: TextStyle(
          color: Colors.green[800],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
