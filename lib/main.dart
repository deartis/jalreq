import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/request_provider.dart';
import 'pages/api_tester_page.dart';

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
        primary: Color(0xFFEF4444),
        secondary: Color(0xFF60A5FA),
        surface: Color(0xFF1A1A1A),
        onSurface: Color(0xFFE0E0E0),
        error: Color(0xFFF87171),
      ),
      scaffoldBackgroundColor: const Color(0xFF0D0D0D),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
        iconTheme: IconThemeData(color: Color(0xFF888888), size: 20),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Color(0xFFEF4444),
        unselectedLabelColor: Color(0xFF666666),
        indicatorColor: Color(0xFFEF4444),
        dividerColor: Color(0xFF2A2A2A),
        labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        labelStyle: const TextStyle(color: Color(0xFF888888), fontSize: 12),
        hintStyle: const TextStyle(color: Color(0xFF444444), fontSize: 12),
        isDense: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF2A2A2A),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: Color(0xFF1F1F1F),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFFEF4444);
          }
          return const Color(0xFF2A2A2A);
        }),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF1A1A1A),
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}
