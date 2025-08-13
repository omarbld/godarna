import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:godarna/providers/auth_provider.dart';
import 'package:godarna/providers/property_provider.dart';
import 'package:godarna/providers/booking_provider.dart';
import 'package:godarna/providers/language_provider.dart';
import 'package:godarna/screens/splash_screen.dart';
import 'package:godarna/constants/app_colors.dart';
import 'package:godarna/constants/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
                // Initialize Supabase
              // TODO: Replace with your actual Supabase credentials
              await Supabase.initialize(
                url: 'https://your-project-id.supabase.co',
                anonKey: 'your-anon-key-here',
              );
  
  runApp(const GoDarnaApp());
}

class GoDarnaApp extends StatelessWidget {
  const GoDarnaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'GoDarna',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.red,
              primaryColor: AppColors.primaryRed,
              scaffoldBackgroundColor: Colors.white,
              fontFamily: 'Cairo',
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
                ),
              ),
            ),
            locale: languageProvider.currentLocale,
            supportedLocales: const [
              Locale('ar', 'MA'), // Arabic (Morocco)
              Locale('fr', 'MA'), // French (Morocco)
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}