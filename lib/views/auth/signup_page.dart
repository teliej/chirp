import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';


class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  // bool isLoading = false;
  bool isSignUpLoading = false;
  bool isGoogleSignUpLoading = false;
  bool isTextObscured = true;
  String? errorMessage; // 🔥 Store auth errors

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return; // Stop if invalid inputs

    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      isSignUpLoading = true;  // 🔥 Start loading
      errorMessage = null;
    });


    try {

      await _authService.register(email, password, username, name);

      // 🔥 After register, always go to verification page
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/verify-email');

      setState(() => errorMessage = null); // clear errors
    } catch (e) {
      // 🔥 Show Firebase or custom errors in UI
      if (!mounted) return; // ✅ Guard before setState
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => isSignUpLoading = false); // 🔥 Stop loading
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
                // color: theme.colorScheme.onPrimary.withOpacity(0.5),
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
                  SizedBox(height: 15),

                  Text(
                    "Create \nAccount.",
                    style: TextStyle(fontSize: 28, color: theme.scaffoldBackgroundColor, fontWeight: FontWeight.bold),
                    softWrap: true, // ✅ wrap text when long
                  ),

                  SizedBox(height: 10),
                ],
              )
            ),

            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey, // 🔥 Use Form for validation
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [

                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: "Name",
                        labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),),
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

                    const SizedBox(height: 5),

                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(labelText: "Username",
                        labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),),
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

                    const SizedBox(height: 5),

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
                    const SizedBox(height: 5),


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
                    const SizedBox(height: 5),

                    // 🔥 AUTH ERROR DISPLAY
                    if (errorMessage != null)
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),

                    const SizedBox(height: 5),

                    // 🔥 CONFIRM PASSWORD FIELD
                    TextFormField(
                      // controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
                      ),
                      obscureText: isTextObscured,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Required!";
                        }
                        if (value != _passwordController.text) {
                          return "Error try again!";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 5),

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
                        onPressed: isSignUpLoading ? null : _submit, // disable when loading
                        child: isSignUpLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text("Sign Up"),
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
                        label: isGoogleSignUpLoading 
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text("Sign up with Google"),

                        onPressed: isGoogleSignUpLoading ? null : () async {
                          setState(() {
                            isGoogleSignUpLoading = true;  // 🔥 Start loading
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
                              setState(() => isGoogleSignUpLoading = false); // 🔥 Stop loading
                            }
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Already have an account?"),

                        TextButton(
                          onPressed: () => setState(() {
                            errorMessage = null;
                            (Navigator.of(context).canPop()) ? Navigator.of(context).pop() : Navigator.pushNamed(context, '/login');

                          }),
                          child: Text('Sign in',
                          textAlign: TextAlign.end,),
                        ),
                      ],
                    )
                  ]
                )
              )
            ),
          ],
        )
      ),
    );
  }
}