import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:revolutionary_commerce/core/theme/app_theme.dart';

void main() {
  test('AppTheme has correct brightness and colors', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Allow runtime fetching to prevent asset errors in dev environment
    GoogleFonts.config.allowRuntimeFetching = true;
    
    final theme = AppTheme.darkTheme;
    
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, const Color(0xFF0A0A0A));
    expect(theme.colorScheme.primary, const Color(0xFF64FFDA));
    expect(theme.useMaterial3, true);
  });
}
