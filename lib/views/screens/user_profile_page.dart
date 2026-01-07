import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../views/tabs_widgets/profile_tab.dart';



class UserProfilePage extends StatelessWidget {
  final String? userId;
  final bool isMe;

  const UserProfilePage ({super.key, required this.userId, this.isMe = false});

  @override
  Widget build(BuildContext context){
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
      body: ProfileTab(
        userId: userId, 
        isMe: isMe,)
    );
  }
}