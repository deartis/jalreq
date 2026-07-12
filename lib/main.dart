import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/request_provider.dart';
import 'pages/api_tester_page.dart';
import 'utils/constants.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => RequestProvider(),
      child: const ApiTesterApp(),
    ),
  );
}

class ApiTesterApp extends StatelessWidget {
  const ApiTesterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JAL REQ',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const ApiTesterPage(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      colorScheme: const ColorScheme.dark(
        primary: kPrimary,
        secondary: kSecondary,
        surface: kSurface,
        onSurface: kOnSurface,
        error: kError,
      ),
      scaffoldBackgroundColor: kBackground,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: kSurface,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: kMuted, size: 20),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: kPrimary,
        unselectedLabelColor: kMuted,
        indicatorColor: kPrimary,
        dividerColor: kBorder,
        labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        labelStyle: const TextStyle(color: kMuted, fontSize: 12),
        hintStyle: const TextStyle(color: kDim, fontSize: 12),
        isDense: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: kBorder,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      popupMenuTheme: const PopupMenuThemeData(color: kSurface),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return kPrimary;
          }
          return kBorder;
        }),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: kSurface,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}
