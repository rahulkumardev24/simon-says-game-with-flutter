import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simon_say_game/provider/them_provider.dart';
import 'package:simon_say_game/screen/game_screen/six_box_screen.dart';
import 'package:simon_say_game/screen/game_selection_screen.dart';
import 'package:simon_say_game/screen/splash%20screen/splash_screen.dart';

void main() {
  /// use for stop device orientation
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    /// them provide
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.white,
        ),
        darkTheme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
        ), // Dark theme background

        home: SplashScreen());
  }
}
