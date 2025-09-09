import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:provider/provider.dart';
// import '../../providers/user_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool isLogin = true; 
  String? errorMessage; // 🔥 Store auth errors

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return; // Stop if invalid inputs

    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
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



        // Load user data into UserProvider
        // if (user != null){
        //   if (!mounted) return; // ✅ Guard before context usage
        //   await context.read<UserProvider>().loadUser(user.uid);
        // }
    
        // Navigate to home if verified
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');



      } else {
        await _authService.register(email, password, username, name);

        // final user = FirebaseAuth.instance.currentUser;
        // if (user != null) {
        //   if (!mounted) return;
        //   await context.read<UserProvider>().loadUser(user.uid);
        // }

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







              // NAME + USERNAME (only when registering)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (child, animation) {
                  final slideAnimation = Tween<Offset>(
                    begin: const Offset(0, -0.1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  ));

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: child,
                    ),
                  );
                },
                child: isLogin
                    ? const SizedBox.shrink(key: ValueKey("login"))
                    : AnimatedSize(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        child: Column(
                          key: const ValueKey("register"),
                          children: [
                            // 🔥 NAME (appears first)
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              builder: (context, value, child) => Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, (1 - value) * -10), // slide down
                                  child: child,
                                ),
                              ),
                              child: TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(labelText: "Name"),
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Name is required";
                                  }
                                  final nameRegex = RegExp(r"^[a-zA-Z\s]{2,}$");
                                  if (!nameRegex.hasMatch(value)) {
                                    return "Enter a valid name (letters only, min 2 chars)";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 10),

                            // 🔥 USERNAME (appears after delay)
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              // add delay
                              builder: (context, value, child) => Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, (1 - value) * -10),
                                  child: child,
                                ),
                              ),
                              child: TextFormField(
                                controller: _usernameController,
                                decoration: const InputDecoration(labelText: "Username"),
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Username is required";
                                  }
                                  final usernameRegex =
                                      RegExp(r"^[a-zA-Z][a-zA-Z0-9_]{2,15}$");
                                  if (!usernameRegex.hasMatch(value)) {
                                    return "Enter a valid username (3–16 chars, letters/numbers/underscore)";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
              ),






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