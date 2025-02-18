import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simon_say_game/provider/them_provider.dart';
import 'package:simon_say_game/utils/custom_text_style.dart';

import 'home_screen.dart'; // Import your HomeScreen or main screen.

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  MediaQueryData? mqData ;
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context) ;
    mqData = MediaQuery.of(context) ;
    return Scaffold(
      backgroundColor: themeProvider.isDark
          ? const Color(0xff161A1D)
          : const Color(0xffe4d9ff),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           Image.asset("assets/icon/logo.png" , width: mqData!.size.width *0.5, fit: BoxFit.cover,) ,
            const SizedBox(height: 20),
            Text(
              'Simon Says',
              style: myTextStyle36(context , fontFamily: "secondary" )
            ),
            Text(
              'Welcome to the Challenge!',
              style: myTextStyle18(context),
            ),
          ],
        ),
      ),
    );
  }
}
