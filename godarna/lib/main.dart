import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

Future<void> _initializeSupabase() async {
  final url = dotenv.env['SUPABASE_URL'];
  final anonKey = dotenv.env['SUPABASE_ANON_KEY'];
  if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
    throw Exception('Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env');
  }
  await Supabase.initialize(url: url, anonKey: anonKey);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await _initializeSupabase();

  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('ar', 'MA'), Locale('fr', 'FR')],
        path: 'assets/translations',
        fallbackLocale: const Locale('ar', 'MA'),
        useOnlyLangCode: false,
        child: const GoDarnaApp(),
      ),
    ),
  );
}