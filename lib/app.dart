import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'views/auth/auth_wrapper.dart';
import 'views/auth/login_page.dart';
import 'views/auth/signup_page.dart';
import 'views/auth/verify_email_page.dart';
import 'views/screens/update_profile.dart';
import 'views/screens/search_page.dart';
import 'views/home_page.dart';
import 'app_theme/theme.dart';



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Chirp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode, // to switch on command
      // themeMode: ThemeMode.system, // to follow system setting
      // home: const AuthWrapper(),

      initialRoute: '/auth-wrapper', // starting screen
      routes: {
        '/auth-wrapper': (context) => const AuthWrapper(),
        '/login': (context) => const LoginPage(),
        '/sign-up': (context) => const SignupPage(),
        '/verify-email': (context) => const VerifyEmailPage(),
        '/update-profile': (context) => const UpdateProfilePage(),
        '/search': (context) => const SearchScreen(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}