import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:simon_say_game/helper/colors.dart';
import 'package:simon_say_game/screen/game_screen/eight_box_screen.dart';
import 'package:simon_say_game/screen/game_screen/four_box_screen.dart';
import 'package:simon_say_game/screen/game_screen/six_box_screen.dart';
import 'package:simon_say_game/utils/custom_text_style.dart';
import 'package:simon_say_game/provider/them_provider.dart';
import 'package:velocity_x/velocity_x.dart';

class GameSelectionScreen extends StatefulWidget {
  @override
  _BoxSelectionScreenState createState() => _BoxSelectionScreenState();
}

class _BoxSelectionScreenState extends State<GameSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  final List<int> availableBoxCounts = [4, 6, 8];
  final Map<int, List<String>> boxColors = {
    4: ["red", "yellow", "green", "blue"],
    6: ["red", "yellow", "green", "blue", "purple", "orange"],
    8: ["red", "yellow", "green", "blue", "purple", "orange", "pink", "teal"],
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;
    final isDarkMode = themeProvider.isDark;

    return Scaffold(
      /// app bar
      appBar: AppBar(
        toolbarHeight: size.height * 0.2,
        flexibleSpace: _appBar(themeProvider, size),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,

      /// body
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Box Selection Cards
                      _buildBoxSelectionGrid(themeProvider, size),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// ----------------------  widgets ------------------------------------- ///

  Widget _appBar(ThemeProvider themeProvider, Size size) {
    return VxArc(
      height: size.height * 0.03,
      edge: VxEdge.bottom,
      arcType: VxArcType.convey,
      child: Container(
          padding: EdgeInsets.all(16),
          width: double.infinity,
          color: themeProvider.isDark
              ? AppColors.darkBackground
              : AppColors.lightPrimary,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "CHOOSE DIFFICULTY",
                style: myTextStyle24(
                  context,
                  fontColor: themeProvider.isDark
                      ? AppColors.darkPrimary
                      : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "More boxes = More challenge!",
                style: myTextStyle18(context,
                    fontFamily: "secondary",
                    fontWeight: FontWeight.bold,
                    fontColor: themeProvider.isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
              SizedBox(height: 15),
            ],
          )),
    );
  }

  Widget _buildBoxSelectionGrid(ThemeProvider themeProvider, Size size) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: 1,
      children: availableBoxCounts.map((count) {
        return Animate(
          effects: [
            FadeEffect(duration: 500.ms, delay: (100 * count).ms),
            ScaleEffect(
                duration: 500.ms,
                delay: (100 * count).ms,
                curve: Curves.elasticOut),
          ],
          child: GestureDetector(
            onTap: () {
              /// Navigate according to selection
              if (count == 4) {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        FourBoxScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    transitionDuration: Duration(milliseconds: 300),
                  ),
                );
              } else if (count == 6) {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        SixBoxScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    transitionDuration: Duration(milliseconds: 300),
                  ),
                );
              }else if(count == 8){

                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        EightBoxScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    transitionDuration: Duration(milliseconds: 300),
                  ),
                );

              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: themeProvider.isDark
                      ? AppColors.darkPrimary
                      : AppColors.lightPrimary,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$count",
                    style: myTextStyle36(context,
                        fontColor: themeProvider.isDark
                            ? AppColors.darkPrimary
                            : AppColors.lightPrimary,
                        fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "BOXES",
                    style: myTextStyle18(context,
                        fontColor: themeProvider.isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: 50,
                    height: 50,
                    child: _buildMiniGrid(count),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMiniGrid(int boxCount) {
    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: boxCount <= 4 ? 2 : 3,
      mainAxisSpacing: 3,
      crossAxisSpacing: 3,
      shrinkWrap: true,
      children: List.generate(boxCount, (index) {
        return Animate(
          effects: [
            ScaleEffect(
              duration: 500.ms,
              delay: (50 * index).ms,
              curve: Curves.elasticOut,
            ),
          ],
          child: Container(
            decoration: BoxDecoration(
              color: _getColorForString(boxColors[boxCount]![index]),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        );
      }),
    );
  }

  Color _getColorForString(String color) {
    switch (color) {
      case "red":
        return Colors.red[400]!;
      case "yellow":
        return Colors.yellow[400]!;
      case "green":
        return Colors.greenAccent[400]!;
      case "blue":
        return Colors.blueAccent[400]!;
      case "purple":
        return Colors.purple[400]!;
      case "orange":
        return Colors.orange[400]!;
      case "pink":
        return Colors.pink[400]!;
      case "teal":
        return Colors.teal[400]!;
      default:
        return Colors.white;
    }
  }
}
