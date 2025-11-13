import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/session_provider.dart';
import 'screens/landing_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const PhysioPlatformApp());
}

class PhysioPlatformApp extends StatelessWidget {
  const PhysioPlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SessionProvider(),
      child: MaterialApp(
        title: 'Physio Platform',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const LandingScreen(),
      ),
    );
  }
}

