import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final _auth = FirebaseAuth.instance;
  bool isEmailVerified = false;
  bool canResendEmail = true;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _checkVerification();
  }

  Future<void> _checkVerification() async {
    await _auth.currentUser?.reload();
    setState(() {
      isEmailVerified = _auth.currentUser?.emailVerified ?? false;
    });
  }

  Future<void> _resendVerificationEmail() async {
    try {
      setState(() => loading = true);

      await _auth.currentUser?.sendEmailVerification();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent!')),
      );

      setState(() {
        canResendEmail = false;
      });

      // allow resend again after 30 seconds
      await Future.delayed(const Duration(seconds: 30));
      setState(() => canResendEmail = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = _auth.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text("Verify Your Email")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "We sent a verification email to:",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(email, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              if (!isEmailVerified)
                const Text(
                  "Please verify your email to continue.",
                  style: TextStyle(color: Colors.red),
                ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: canResendEmail && !loading
                    ? _resendVerificationEmail
                    : null,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Resend Email"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await _checkVerification();
                  if (isEmailVerified) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email verified!')),
                    );
                    // Navigate to your main app/home
                    Navigator.pushReplacementNamed(context, '/home');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Email not verified yet. Please check again.')),
                    );
                  }
                },
                child: const Text("Continue"),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  await _auth.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
