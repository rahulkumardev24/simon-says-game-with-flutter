import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:simon_say_game/helper/colors.dart';
import 'package:simon_say_game/screen/game_screen/eight_box_screen.dart';
import 'package:simon_say_game/screen/game_screen/four_box_screen.dart';
import 'package:simon_say_game/screen/game_screen/six_box_screen.dart';
import 'package:simon_say_game/screen/game_screen/ten_box_screen.dart';
import 'package:simon_say_game/utils/app_utils.dart';
import 'package:simon_say_game/utils/custom_text_style.dart';
import 'package:simon_say_game/provider/them_provider.dart';
import 'package:simon_say_game/widgets/my_icon_button.dart';
import 'package:velocity_x/velocity_x.dart';
import '../helper/my_dialogs.dart';
import 'game_screen/game_rule_screen.dart';

class GameSelectionScreen extends StatefulWidget {
  @override
  _GameSelectionScreenState createState() => _GameSelectionScreenState();
}

class _GameSelectionScreenState extends State<GameSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  final List<int> availableBoxCounts = [4, 6, 8, 10];
  final Map<int, List<String>> boxColors = {
    4: ["red", "yellow", "green", "blue"],
    6: ["red", "yellow", "green", "blue", "purple", "orange"],
    8: ["red", "yellow", "green", "blue", "purple", "orange", "pink", "teal"],
    10: [
      "red",
      "yellow",
      "green",
      "blue",
      "purple",
      "orange",
      "pink",
      "teal",
      "brown",
      "cyan"
    ],
  };

  bool isMute = true;
  bool isLight = true;
  bool isVibrate = true;

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

    /// setting data get
    _loadSettingData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadSettingData() async {
    bool loadVibration = await AppUtils.loadVibration();
    bool loadMute = await AppUtils.loadMute();
    setState(() {
      isVibrate = loadVibration;
      isMute = loadMute;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;
    final isDarkMode = themeProvider.isDark;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: size.height * 0.3,
        flexibleSpace: _buildAppBar(isDarkMode, size),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
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

  Widget _buildAppBar(bool isDarkMode, Size size) {
    return VxArc(
      height: size.height * 0.03,
      edge: VxEdge.bottom,
      arcType: VxArcType.convey,
      child: Container(
        padding: EdgeInsets.all(16),
        width: double.infinity,
        color:
            isDarkMode ? AppColors.darkCardBackground : AppColors.lightPrimary,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(
              flex: 1,
            ),

            /// Setting
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                /// volume button
                MyIconButton(
                    icon: FontAwesomeIcons.volumeLow,
                    iconColor: !isMute
                        ? AppColors.darkIconSecondary.withValues(alpha: 0.6)
                        : isDarkMode
                            ? AppColors.darkIconPrimary
                            : AppColors.lightIconSecondary,
                    backgroundColor: !isMute
                        ? AppColors.lightDisable
                        : isDarkMode
                            ? AppColors.darkPrimary
                            : AppColors.lightBackground.withValues(alpha: 0.9),
                    onTap: () {
                      setState(() {
                        isMute = !isMute;
                      });
                      AppUtils.saveMute(isMute);
                    }),

                /// vibration
                MyIconButton(
                    icon: Icons.vibration_rounded,
                    iconColor: !isVibrate
                        ? AppColors.darkIconSecondary.withValues(alpha: 0.6)
                        : isDarkMode
                            ? AppColors.darkIconPrimary
                            : AppColors.lightIconSecondary,
                    backgroundColor: !isVibrate
                        ? AppColors.lightDisable
                        : isDarkMode
                            ? AppColors.darkPrimary
                            : AppColors.lightBackground.withValues(alpha: 0.9),
                    onTap: () {
                      setState(() {
                        isVibrate = !isVibrate;
                      });
                      AppUtils.saveVibration(isVibrate);
                    }),

                /// light and dark them
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return MyIconButton(
                        icon: themeProvider.isDark
                            ? FontAwesomeIcons.solidSun
                            : FontAwesomeIcons.solidMoon,
                        iconColor: isDarkMode
                            ? AppColors.darkIconPrimary
                            : AppColors.lightIconSecondary,
                        backgroundColor: isDarkMode
                            ? AppColors.darkPrimary
                            : AppColors.lightBackground.withValues(alpha: 0.9),
                        onTap: () {
                          themeProvider.toggleTheme();
                        });
                  },
                ),

                /// share
                MyIconButton(
                    icon: FontAwesomeIcons.shareNodes,
                    iconColor: isDarkMode
                        ? AppColors.darkIconPrimary
                        : AppColors.lightIconSecondary,
                    backgroundColor: isDarkMode
                        ? AppColors.darkPrimary
                        : AppColors.lightBackground.withValues(alpha: 0.9),
                    onTap: () => MyDialogs.shareApp(context)),

                /// Game Rule
                MyIconButton(
                    icon: FontAwesomeIcons.info,
                    iconColor: isDarkMode
                        ? AppColors.darkIconPrimary
                        : AppColors.lightIconSecondary,
                    backgroundColor: isDarkMode
                        ? AppColors.darkPrimary
                        : AppColors.lightBackground.withValues(alpha: 0.9),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => GameRulesScreen()))),
              ],
            ),

            Spacer(),
            Text(
              "CHOOSE DIFFICULTY",
              style: myTextStyle24(
                context,
                fontColor: isDarkMode
                    ? AppColors.darkPrimary
                    : AppColors.lightTextPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "More boxes = More challenge!",
              style: myTextStyle18(
                context,
                fontFamily: "secondary",
                fontWeight: FontWeight.bold,
                fontColor: isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            Spacer(
              flex: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoxSelectionGrid(ThemeProvider themeProvider, Size size) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1,
      children: availableBoxCounts.map((count) {
        return Animate(
          effects: [
            FadeEffect(duration: 500.ms, delay: (100 * count).ms),
            ScaleEffect(
              duration: 500.ms,
              delay: (100 * count).ms,
              curve: Curves.elasticOut,
            ),
          ],
          child: GestureDetector(
            onTap: () => _navigateToGameScreen(count),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    themeProvider.isDark
                        ? AppColors.darkPrimary.withOpacity(0.1)
                        : AppColors.lightPrimary.withOpacity(0.1),
                    themeProvider.isDark
                        ? AppColors.darkPrimary.withOpacity(0.3)
                        : AppColors.lightPrimary.withOpacity(0.3),
                  ],
                ),
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
                    style: myTextStyle36(
                      context,
                      fontColor: themeProvider.isDark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "BOXES",
                    style: myTextStyle18(
                      context,
                      fontColor: themeProvider.isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: boxCountToMiniGridSize(count),
                    height: boxCountToMiniGridSize(count),
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

  double boxCountToMiniGridSize(int count) {
    if (count <= 4) return 50;
    if (count <= 6) return 60;
    return 70;
  }

  Widget _buildMiniGrid(int boxCount) {
    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: boxCount <= 4
          ? 2
          : boxCount <= 6
              ? 3
              : 4,
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
                border:
                    Border.all(width: 1, color: AppColors.darkCardBackground)),
          ),
        );
      }),
    );
  }

  void _navigateToGameScreen(int boxCount) {
    Widget screen;
    switch (boxCount) {
      case 4:
        screen = FourBoxScreen();
        break;
      case 6:
        screen = SixBoxScreen();
        break;
      case 8:
        screen = EightBoxScreen();
        break;
      case 10:
        screen = TenBoxScreen();
        break;
      default:
        screen = FourBoxScreen();
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 300),
      ),
    );
  }

  Color _getColorForString(String color) {
    switch (color) {
      case "red":
        return Colors.red[400]!;
      case "yellow":
        return Colors.yellow[400]!;
      case "green":
        return Colors.green[400]!;
      case "blue":
        return Colors.blue[400]!;
      case "purple":
        return Colors.purple[400]!;
      case "orange":
        return Colors.orange[400]!;
      case "pink":
        return Colors.pink[400]!;
      case "teal":
        return Colors.teal[400]!;
      case "brown":
        return Colors.brown[400]!;
      case "cyan":
        return Colors.cyan[400]!;
      default:
        return Colors.grey[400]!;
    }
  }
}
