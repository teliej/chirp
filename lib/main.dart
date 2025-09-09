import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/mock_data_service.dart';
import 'app.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/post_provider.dart';
import 'providers/user_provider.dart';
// import 'providers/auth_provider.dart';

// import 'views/tabs_widgets/notifications_tab.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: ".env"); // .env
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await MockDataService().loadAllData(); // Load once
  // await _NotificationTabState.init(); // Initialize local notifications


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final userProvider = UserProvider();
            userProvider.listenToAuthChanges(); // 👈 start listening once
            return userProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
      ],
      child: const MyApp(),
    ),
  );
}


// log output

// W/LocalRequestInterceptor( 6383): Error getting App Check token; using placeholder token instead. Error: com.google.firebase.FirebaseException: No AppCheckProvider installed.
// D/FirebaseAuth( 6383): Notifying id token listeners about user ( IKQXLJCr1VhBOk1xLgYx4EcxWha2 ).
// D/FirebaseAuth( 6383): Notifying auth state listeners about user ( IKQXLJCr1VhBOk1xLgYx4EcxWha2 ).


// I/flutter ( 6383): user_service getUser: {savedPosts: [], role: user, lastActive: Timestamp(seconds=1757202167, nanoseconds=91937000), isVerified: false, avatarUrl: , bio: , bioLink: , posts: [], createdAt: Timestamp(seconds=1757202167, nanoseconds=91926000), followers: 0, following: 0, name: , location: null, interests: [], email: teliej52@gmail.com, backgroundImageUrl: , username: teliej52, updatedAt: null}


// I/m.example.chirp( 6383): Compiler allocated 6498KB to compile void android.view.ViewRootImpl.performTraversals()