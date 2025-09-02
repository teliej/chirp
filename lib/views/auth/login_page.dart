import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool isLogin = true; 
  String? errorMessage; // 🔥 Store auth errors

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return; // Stop if invalid inputs

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (isLogin) {
        await _authService.signIn(email, password);

        // 🔥 Check email verification status
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && !user.emailVerified) {
          // system may be using a cached currentUser
          await user.reload(); // refresh user state
          await user.sendEmailVerification();

          if (!mounted) return; // ✅ Guard before navigation
          Navigator.pushReplacementNamed(context, '/verify-email');
          return;
        }

        // Navigate to home if verified
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        await _authService.register(email, password);

        // 🔥 After register, always go to verification page
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/verify-email');
      }

      setState(() => errorMessage = null); // clear errors
    } catch (e) {
      // 🔥 Show Firebase or custom errors in UI
      if (!mounted) return; // ✅ Guard before setState
      setState(() {
        errorMessage = e.toString();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey, // 🔥 Use Form for validation
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLogin ? "Login" : "Register",
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(height: 20),

              // 🔥 EMAIL FIELD
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email is required";
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) {
                    return "Enter a valid email";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // 🔥 PASSWORD FIELD
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Password is required";
                  }
                  if (value.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 🔥 AUTH ERROR DISPLAY
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 10),

              // 🔥 SUBMIT BUTTON
              ElevatedButton(
                onPressed: _submit,
                child: Text(isLogin ? "Login" : "Register"),
              ),

              // 🔥 SWITCH LOGIN / REGISTER
              TextButton(
                onPressed: () => setState(() {
                  isLogin = !isLogin;
                  errorMessage = null;
                }),
                child: Text(isLogin ? "Create account" : "I have an account"),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.g_mobiledata),
                label: const Text("Sign in with Google"),
                onPressed: () async {
                  final ctx = context;
                  try {
                    final user = await _authService.signInWithGoogle();
                    if (!mounted) return; // ✅ Guard before navigation
                    if (user != null && ctx.mounted) {
                      Navigator.pushReplacementNamed(ctx, '/home'); // 🔥 Go straight home
                    }
                  } catch (e) {
                    if (!mounted) return; // ✅ Guard before setState
                    setState(() => errorMessage = e.toString());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}