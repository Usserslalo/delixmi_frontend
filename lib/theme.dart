import 'package:flutter/material.dart';

class AppTheme {
  // Colores basados en la paleta de TailwindCSS
  static const Color primaryColor = Color(0xFFF2843A);
  static const Color backgroundLight = Color(0xFFF8F7F6);
  static const Color backgroundDark = Color(0xFF221710);
  static const Color textLight = Color(0xFF1C130D);
  static const Color textDark = Color(0xFFF8F7F6);
  static const Color textMutedLight = Color(0xFF9B6B4B);
  static const Color textMutedDark = Color(0xFFA19B96);
  static const Color inputLight = Color(0xFFF3ECE7);
  static const Color inputDark = Color(0xFF3A2D23);

  // Tema claro
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      // // fontFamily: 'PlusJakartaSans' // Comentado hasta descargar las fuentes, // Comentado hasta descargar las fuentes
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        surface: backgroundLight,
        onSurface: textLight,
        onSurfaceVariant: textMutedLight,
      ),
      
      // Configuración del AppBar
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textLight,
      ),
      
      // Configuración de botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            // fontFamily: 'PlusJakartaSans' // Comentado hasta descargar las fuentes,
          ),
        ),
      ),
      
      // Configuración de campos de texto
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: TextStyle(
          color: textMutedLight,
          // fontFamily: 'PlusJakartaSans' // Comentado hasta descargar las fuentes,
        ),
        labelStyle: TextStyle(
          color: textLight,
          // fontFamily: 'PlusJakartaSans' // Comentado hasta descargar las fuentes,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Configuración de texto
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          // fontFamily: 'PlusJakartaSans' // Comentado hasta descargar las fuentes,
          fontWeight: FontWeight.w800,
          fontSize: 32,
          color: textLight,
        ),
        headlineLarge: TextStyle(
          // fontFamily: 'PlusJakartaSans' // Comentado hasta descargar las fuentes,
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: textLight,
        ),
        titleLarge: TextStyle(
          // fontFamily: 'PlusJakartaSans' // Comentado hasta descargar las fuentes,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: textLight,
        ),
        titleMedium: TextStyle(
          // fontFamily: 'PlusJakartaSans' // Comentado hasta descargar las fuentes,
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: textLight,
        ),
        bodyLarge: TextStyle(
          // fontFamily: 'PlusJakartaSans' // Comentado hasta descargar las fuentes,
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: textLight,
        ),
        bodyMedium: TextStyle(
          // fontFamily: 'PlusJakartaSans' // Comentado hasta descargar las fuentes,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: textLight,
        ),
        bodySmall: TextStyle(
          // fontFamily: 'PlusJakartaSans' // Comentado hasta descargar las fuentes,
          fontWeight: FontWeight.w400,
          fontSize: 12,
          color: textMutedLight,
        ),
        labelLarge: TextStyle(
          // fontFamily: 'PlusJakartaSans' // Comentado hasta descargar las fuentes,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: textLight,
        ),
      ),
      
      // Configuración de botones de texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            // fontFamily: 'PlusJakartaSans' // Comentado hasta descargar las fuentes,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      
      // Configuración de cards
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Configuración del scaffold
      scaffoldBackgroundColor: backgroundLight,
    );
  }

  // Tema oscuro (para futuras implementaciones)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      // fontFamily: 'PlusJakartaSans' // Comentado hasta descargar las fuentes,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        surface: backgroundDark,
        onSurface: textDark,
        onSurfaceVariant: textMutedDark,
      ),
      
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textDark,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            // fontFamily: 'PlusJakartaSans' // Comentado hasta descargar las fuentes,
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(
          color: textMutedDark,
          // fontFamily: 'PlusJakartaSans' // Comentado hasta descargar las fuentes,
        ),
        labelStyle: const TextStyle(
          color: textDark,
          // fontFamily: 'PlusJakartaSans' // Comentado hasta descargar las fuentes,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          // fontFamily: 'PlusJakartaSans' // Comentado hasta descargar las fuentes,
          fontWeight: FontWeight.w800,
          fontSize: 32,
          color: textDark,
        ),
        headlineLarge: TextStyle(
          // fontFamily: 'PlusJakartaSans' // Comentado hasta descargar las fuentes,
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: textDark,
        ),
        titleLarge: TextStyle(
          // fontFamily: 'PlusJakartaSans' // Comentado hasta descargar las fuentes,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: textDark,
        ),
        titleMedium: TextStyle(
          // fontFamily: 'PlusJakartaSans' // Comentado hasta descargar las fuentes,
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: textDark,
        ),
        bodyLarge: TextStyle(
          // fontFamily: 'PlusJakartaSans' // Comentado hasta descargar las fuentes,
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: textDark,
        ),
        bodyMedium: TextStyle(
          // fontFamily: 'PlusJakartaSans' // Comentado hasta descargar las fuentes,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: textDark,
        ),
        bodySmall: TextStyle(
          // fontFamily: 'PlusJakartaSans' // Comentado hasta descargar las fuentes,
          fontWeight: FontWeight.w400,
          fontSize: 12,
          color: textMutedDark,
        ),
        labelLarge: TextStyle(
          // fontFamily: 'PlusJakartaSans' // Comentado hasta descargar las fuentes,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: textDark,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            // fontFamily: 'PlusJakartaSans' // Comentado hasta descargar las fuentes,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      
      cardTheme: CardThemeData(
        color: inputDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      scaffoldBackgroundColor: backgroundDark,
    );
  }
}
