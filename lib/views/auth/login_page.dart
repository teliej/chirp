import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import 'signup_page.dart';


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

  // bool isLoading = false;
  bool isSignInLoading = false;
  bool isGoogleSignInLoading = false;
  bool isTextObscured = true;
  String? errorMessage; // 🔥 Store auth errors

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return; // Stop if invalid inputs

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      isSignInLoading = true;  // 🔥 Start loading
      errorMessage = null;
    });

    try {

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

      setState(() => errorMessage = null); // clear errors
    } catch (e) {
      // 🔥 Show Firebase or custom errors in UI
      if (!mounted) return; // ✅ Guard before setState
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => isSignInLoading = false); // 🔥 Stop loading
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // keep transparent, content goes behind
          statusBarIconBrightness:
              theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: theme.scaffoldBackgroundColor,
          systemNavigationBarIconBrightness:
              theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        ),
      );
    });


    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ allows screen to resize when keyboard shows
      body: SingleChildScrollView( // 👇 make body scrollable
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(.8),
                borderRadius: BorderRadius.only(
                  bottomLeft: const Radius.circular(50)
            
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  SizedBox(height: 30),
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: theme.scaffoldBackgroundColor,),
                    iconSize: 25,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () => (Navigator.of(context).canPop()) ? Navigator.of(context).pop() : (){},
                  ),
                  SizedBox(height: 25),

                  Text(
                    "Welcome \nBack!",
                    style: TextStyle(fontSize: 28, color: theme.scaffoldBackgroundColor, fontWeight: FontWeight.bold),
                    softWrap: true, // ✅ wrap text when long
                  ),

                  Text(
                    "Continue your adventure.",
                    style: TextStyle(color: theme.scaffoldBackgroundColor, fontWeight: FontWeight.bold),
                    softWrap: true, // ✅ wrap text when long
                  ),

                  SizedBox(height: 20),
                ],
              )
            ),

            const SizedBox(height: 90),

            // FORM
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey, // 🔥 Use Form for validation
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 🔥 EMAIL FIELD
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email", 
                        labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),),
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
                    const SizedBox(height: 15),


                    // 🔥 PASSWORD FIELD
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: "Password",
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isTextObscured = !isTextObscured; // toggle
                            });
                          },
                          icon: Icon(
                            isTextObscured 
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                            size: 18,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
                      ),
                      obscureText: isTextObscured,
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
                    const SizedBox(height: 10),

                    // 🔥 AUTH ERROR DISPLAY
                    if (errorMessage != null)
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),

                    const SizedBox(height: 40),

                    // 🔥 SUBMIT BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isSignInLoading ? null : _submit, // disable when loading
                        child: isSignInLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text("Sign In"),
                      ),
                    ),


                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        icon: Transform.rotate(
                          angle: -20 * 3.1415926535 / 180, // convert degrees to radians
                          child: const Icon(Icons.g_mobiledata, size: 35),
                        ),
                        label: isGoogleSignInLoading 
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text("Sign in with Google"),

                        onPressed: isGoogleSignInLoading ? null : () async {
                          setState(() {
                            isGoogleSignInLoading = true;  // 🔥 Start loading
                            errorMessage = null;
                          });
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
                          } finally {
                            if (mounted) {
                              setState(() => isGoogleSignInLoading = false); // 🔥 Stop loading
                            }
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 5),

                    // 🔥 SWITCH LOGIN / REGISTER
                    TextButton(
                      onPressed: () => setState(() {
                        errorMessage = null;
                        // Navigator.pushNamed(context, '/sign-up');
                        Navigator.of(context).push(_createRoute());



                      }),
                      child: Text("Create account"),
                    ),
                  ]
                )
              )
            ),
          ],
        )
      )
    );
  }
}











Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const SignupPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // 👈 Slide from right
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      final tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
