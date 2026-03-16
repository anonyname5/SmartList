import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shad_ui_flutter/shad_ui_flutter.dart';

import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: SmartListApp()));
}

class SmartListApp extends ConsumerWidget {
  const SmartListApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const lightPrimary = Color(0xFF1F3A5F);
    const lightSecondary = Color(0xFF3E5C76);
    const lightAccent = Color(0xFF2A9D8F);
    const lightSurface = Color(0xFFFFFFFF);
    const lightBackground = Color(0xFFF6F8FB);
    const lightOnSurface = Color(0xFF1D2733);

    const darkPrimary = Color(0xFF8FB6E8);
    const darkSecondary = Color(0xFFAAC7E5);
    const darkAccent = Color(0xFF66C4B6);
    const darkSurface = Color(0xFF1B2430);
    const darkBackground = Color(0xFF111827);
    const darkOnSurface = Color(0xFFEAF2FB);

    final themeMode = ref.watch(themeModeProvider);
    final effectiveBrightness = themeMode == ThemeMode.system
        ? MediaQuery.platformBrightnessOf(context)
        : (themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light);
    final isDark = effectiveBrightness == Brightness.dark;

    return ShadTheme(
      data: isDark ? ShadThemeData.dark() : ShadThemeData.light(),
      child: MaterialApp(
        title: 'SmartList',
        debugShowCheckedModeBanner: false,
        themeMode: themeMode,
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: lightPrimary,
            secondary: lightSecondary,
            tertiary: lightAccent,
            surface: lightSurface,
            onSurface: lightOnSurface,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: lightBackground,
          appBarTheme: const AppBarTheme(
            backgroundColor: lightBackground,
            foregroundColor: lightOnSurface,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: lightOnSurface,
            ),
          ),
          cardTheme: CardThemeData(
            color: lightSurface,
            elevation: 1,
            shadowColor: const Color(0x14000000),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: EdgeInsets.zero,
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: lightPrimary,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: lightPrimary,
            foregroundColor: Colors.white,
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: lightSurface,
            indicatorColor: const Color(0x1A1F3A5F),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return TextStyle(
                color: selected ? lightPrimary : const Color(0xFF607185),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              );
            }),
          ),
          chipTheme: ChipThemeData(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: const Color(0xFFF0F3F8),
            selectedColor: const Color(0x1F2A9D8F),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              color: lightOnSurface,
            ),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          checkboxTheme: CheckboxThemeData(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            fillColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.selected) ? lightAccent : null;
            }),
          ),
          dividerTheme: const DividerThemeData(
            color: Color(0xFFE6EBF2),
            thickness: 1,
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: lightSurface,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDCE3ED)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: lightPrimary, width: 1.4),
            ),
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: const ColorScheme.dark(
            primary: darkPrimary,
            secondary: darkSecondary,
            tertiary: darkAccent,
            surface: darkSurface,
            onSurface: darkOnSurface,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: darkBackground,
          appBarTheme: const AppBarTheme(
            backgroundColor: darkBackground,
            foregroundColor: darkOnSurface,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: darkOnSurface,
            ),
          ),
          cardTheme: CardThemeData(
            color: darkSurface,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: EdgeInsets.zero,
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: darkPrimary,
              foregroundColor: const Color(0xFF0F172A),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: darkPrimary,
            foregroundColor: Color(0xFF0F172A),
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: const Color(0xFF0F172A),
            indicatorColor: const Color(0x332A9D8F),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return TextStyle(
                color: selected ? darkPrimary : const Color(0xFF9CAFC5),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              );
            }),
          ),
          chipTheme: ChipThemeData(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: const Color(0xFF243244),
            selectedColor: const Color(0x332A9D8F),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              color: darkOnSurface,
            ),
            side: const BorderSide(color: Color(0xFF334155)),
          ),
          checkboxTheme: CheckboxThemeData(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            fillColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.selected) ? darkAccent : null;
            }),
          ),
          dividerTheme: const DividerThemeData(
            color: Color(0xFF334155),
            thickness: 1,
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: const Color(0xFF243244),
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3A4A5F)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: darkPrimary, width: 1.4),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
