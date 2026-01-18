import 'package:flutter/material.dart';

/// App color scheme
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color accent = Color(0xFFFF9800);
  
  // Region Colors
  static const Color northColor = Color(0xFFE53935); // Red for North
  static const Color centralColor = Color(0xFF1E88E5); // Blue for Central
  static const Color southColor = Color(0xFFFDD835); // Yellow for South
  
  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Colors.white;
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Prize Colors (for different prize levels)
  static const Color specialPrize = Color(0xFFD32F2F);
  static const Color firstPrize = Color(0xFFE64A19);
  static const Color secondPrize = Color(0xFFF57C00);
  static const Color thirdPrize = Color(0xFFFBC02D);
  static const Color consolationPrize = Color(0xFF7CB342);
  
  // Gradient Colors
  static const LinearGradient northGradient = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFC62828)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient centralGradient = LinearGradient(
    colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient southGradient = LinearGradient(
    colors: [Color(0xFFFDD835), Color(0xFFF9A825)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
