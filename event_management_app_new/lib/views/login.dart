import 'package:event_management_app/auth.dart';
import 'package:event_management_app/constants/colors.dart';
import 'package:event_management_app/containers/custom_input_form.dart';
import 'package:event_management_app/views/homepage.dart';
import 'package:event_management_app/views/signup.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false; // 👈 Tracks if login is in progress

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email and password.")),
      );
      return;
    }

    setState(() => _isLoading = true); // 👈 Start loading

    final result = await loginUser(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false); // 👈 Stop loading

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Successful!")),
      );
      Future.delayed(
        const Duration(seconds: 1),
            () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Homepage()),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            Text(
              "Login",
              style: TextStyle(
                color: kLightGreen,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            CustomInputForm(
              controller: _emailController,
              icon: Icons.email_outlined,
              label: "Email",
              hint: "Enter your Email",
            ),
            const SizedBox(height: 8),
            CustomInputForm(
              obscureText: true,
              controller: _passwordController,
              icon: Icons.lock_outline_rounded,
              label: "Password",
              hint: "Enter your Password",
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Forget Password",
                  style: TextStyle(
                    color: kLightGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin, // 👈 Disable when loading
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                  _isLoading ? Colors.grey : kLightGreen, // 👈 Dim while loading
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
                    : const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _isLoading
                  ? null
                  : () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SignUpPage()),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Create a New Account?",
                    style: TextStyle(
                      color: kLightGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Sign Up",
                    style: TextStyle(
                      color: kLightGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
