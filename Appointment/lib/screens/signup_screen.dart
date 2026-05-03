import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import 'home_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    void handleSignup() async {
      final error = await authService.signup(
        emailController.text,
        passwordController.text,
      );

      if (error == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text("Signup"),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CustomTextField(controller: nameController, label: "Full Name"),
            const SizedBox(height: 20),
            CustomTextField(controller: emailController, label: "Email"),
            const SizedBox(height: 20),
            CustomTextField(
              controller: passwordController,
              label: "Password",
              isPassword: true,
            ),
            const SizedBox(height: 30),
            CustomButton(text: "Create Account", onPressed: handleSignup),
          ],
        ),
      ),
    );
  }
}
