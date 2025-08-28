import 'package:flutter/material.dart';
import 'services/mock_data_service.dart';
import 'app.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MockDataService().loadAllData(); // Load once
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
  // runApp(const MyApp());
}