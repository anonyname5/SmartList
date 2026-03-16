import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shad_ui_flutter/shad_ui_flutter.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: SmartListApp()));
}

class SmartListApp extends StatelessWidget {
  const SmartListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadTheme(
      data: ShadThemeData.light(),
      child: MaterialApp(
        title: 'SmartList',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.teal.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.teal, width: 1.4),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
