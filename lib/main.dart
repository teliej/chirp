import 'package:flutter/material.dart';
import 'app.dart';
// firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// services
import 'services/mock_data_service.dart';
// providers
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