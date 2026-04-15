import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/constants.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/restaurant_provider.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  await authProvider.loadToken();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
      ],
      child: RestaurantAdminApp(authProvider: authProvider),
    ),
  );
}

class RestaurantAdminApp extends StatefulWidget {
  final AuthProvider authProvider;
  const RestaurantAdminApp({super.key, required this.authProvider});

  @override
  State<RestaurantAdminApp> createState() => _RestaurantAdminAppState();
}

class _RestaurantAdminAppState extends State<RestaurantAdminApp> {
  late final router = createRouter(widget.authProvider);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Restaurant Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.rubyRed,
          primary: AppColors.rubyRed,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: AppColors.ivory,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.rubyRed,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.rubyRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.rubyRed, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      routerConfig: router,
    );
  }
}

