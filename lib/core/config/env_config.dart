import 'package:flutter/foundation.dart';

class EnvConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static const String _openaiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  static const String astrologyApiKey = String.fromEnvironment(
    'ASTROLOGY_API_KEY',
    defaultValue: '',
  );

  static String get openaiApiKey {
    if (kIsWeb) {
      // Prevents exposing the key in the client-side bundle
      return ''; 
    }
    return _openaiApiKey;
  }

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
