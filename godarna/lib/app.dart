import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/router.dart';
import 'config/theme.dart';

class GoDarnaApp extends StatelessWidget {
  const GoDarnaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = buildAppTheme(context);
    return MaterialApp.router(
      title: 'GoDarna',
      debugShowCheckedModeBanner: false,
      theme: theme.copyWith(
        textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(theme.textTheme),
      ),
      routerConfig: buildRouter(),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
    );
  }
}