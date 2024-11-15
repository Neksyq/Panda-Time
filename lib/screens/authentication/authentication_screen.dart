import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pandatime/models/user_model.dart';
import 'package:pandatime/repositories/user_repository.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

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
                _buildTextField(
                    label: 'Email',
                    obscureText: false,
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    }),
                const SizedBox(height: 20),
                _buildTextField(
                    label: 'Password',
                    obscureText: true,
                    controller: passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters long';
                      }
                      if (!RegExp(r'[A-Z]').hasMatch(value)) {
                        return 'Password must contain at least one uppercase letter';
                      }
                      if (!RegExp(r'[a-z]').hasMatch(value)) {
                        return 'Password must contain at least one lowercase letter';
                      }
                      if (!RegExp(r'[0-9]').hasMatch(value)) {
                        return 'Password must contain at least one number';
                      }
                      if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                        return 'Password must contain at least one special character';
                      }
                      return null;
                    }),
                if (!isLogin) ...[
                  const SizedBox(height: 20),
                  _buildTextField(
                      label: 'Confirm Password',
                      obscureText: true,
                      controller: confirmPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      }),
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

  Widget _buildTextField({
    required String label,
    bool obscureText = false,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
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
        onPressed: () async {
          await _handleAuthButtonClick();
        },
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
    return ElevatedButton.icon(
      onPressed: () async {
        await _handleGoogleButtonClick(context);
      },
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
      label: Text(
        isLogin ? 'Sign in with Google' : 'Sign up with Google',
      ),
    );
  }

  Future<void> _handleAuthButtonClick() async {
    try {
      final email = emailController.text.trim();
      final password = emailController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        //_showErrorDialog()
        return;
      }

      if (isLogin) {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
      } else {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        final user = UserModel(
            id: userCredential.user!.uid, email: email, password: password);
        await UserRepository().addUser(user);
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/panda_home');
    } catch (error) {
      //_showErrorDialog('An error occurred: $error');
      print('Auth error: $error');
    }
  }

  Future<void> _handleGoogleButtonClick(BuildContext context) async {
    final UserCredential? user = await _handleGoogleSignIn();

    if (!context.mounted) return;

    // Navigate to the next screen
    Navigator.pushReplacementNamed(context, '/panda_home');
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

  Future<UserCredential?> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (error) {
      throw Exception('SignInFailed $error');
    }
  }
}
