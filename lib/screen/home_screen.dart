import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simon_say_game/helper/colors.dart';
import 'package:simon_say_game/helper/my_dialogs.dart';
import 'package:simon_say_game/utils/custom_text_style.dart';

import '../provider/them_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _SimonSaysGameState createState() => _SimonSaysGameState();
}

class _SimonSaysGameState extends State<HomeScreen> {
  final String playStoreLink =
      "https://play.google.com/store/apps/details?id=com.appcreatorrahul.simonsay";

  List<String> gameSeq = [];
  List<String> userSeq = [];
  List<String> colors = ["blue", "green", "red", "yellow"];
  bool started = false;
  int level = 0;
  bool userTurn = false;
  bool gameOver = false;
  int score = 0;
  int maxScore = 0;

  bool isMute = true;
  bool isLight = true;

  Map<String, bool> flashMap = {
    "red": false,
    "yellow": false,
    "green": false,
    "blue": false
  };

  /// audio play
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    loadMaxScore();
    loadMute();
  }

  /// -----Game Start function-----------///
  void startGame() {
    setState(() {
      started = true;
      gameOver = false;
      level = 0;
      score = 0;
      gameSeq.clear();
      userSeq.clear();
      userTurn = false;
    });
    levelUp();
  }

  ///-------Level up functions---------------///
  void levelUp() {
    setState(() {
      userSeq.clear();
      level++;
      userTurn = false;
    });

    /// Increase score based on the level
    if (level == 1) {
      score += 0;
    } else if (level <= 3) {
      score += 2;
    } else if (level <= 6) {
      score += 5;
    } else if (level <= 10) {
      score += 10;
    } else {
      score += 20;
    }

    /// Check and update the maxScore if needed
    if (score > maxScore) {
      maxScore = score;
    }

    /// call the function to save the max score into shared preference
    saveMaxScore();

    /// random index generate
    int randIdx = Random().nextInt(colors.length);
    String randomColor = colors[randIdx];
    gameSeq.add(randomColor);

    /// call function flashSequence
    flashSequence();
  }

  /// flashSequence function
  Future<void> flashSequence() async {
    for (String color in gameSeq) {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        flashMap[color] = true;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        flashMap[color] = false;
      });
    }
    setState(() {
      userTurn = true;
    });
  }

  /// user press functions
  void userPress(String color) {
    if (!userTurn) return;

    if (isMute) audioPlayer.play(AssetSource('audio/tap.mp3'));

    setState(() {
      userSeq.add(color);
      flashMap[color] = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        flashMap[color] = false;
      });

      checkAnswer(userSeq.length - 1);
    });
  }

  /// ans check functions
  void checkAnswer(int idx) {
    if (userSeq[idx] != gameSeq[idx]) {
      gameOverSequence();
      return;
    }

    if (userSeq.length == gameSeq.length) {
      setState(() {
        userTurn = false;
      });
      Future.delayed(const Duration(milliseconds: 1000), levelUp);
    }
  }

  /// game over functions
  void gameOverSequence() {
    if (isMute) audioPlayer.play(AssetSource("audio/over.mp3"));
    setState(() {
      gameOver = true;
      started = false;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        gameSeq.clear();
        userSeq.clear();
      });
    });
  }

  ///------------------ SHARED PREFERENCES--------------------------///

  /// Load max score from SharedPreferences
  void loadMaxScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      maxScore = prefs.getInt('maxScore') ?? 0;
    });
  }

  /// Save max score to SharedPreferences
  void saveMaxScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('maxScore', maxScore);
  }

  /// -------------- Mute and unMute functions ------------------- ///
  void saveMute() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool("checkMute", isMute);
  }

  void loadMute() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      isMute = preferences.getBool("checkMute") ?? true;
    });
  }

  MediaQueryData? mqData;
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    mqData = MediaQuery.of(context);
    return Scaffold(
      /// --------------------APPBAR------------------------///
      appBar: AppBar(
        /// title
        title: Text(
          "Simon says",
          style: myTextStyle24(context,
              fontColor: Colors.white, fontFamily: "secondary"),
        ),
        backgroundColor: themeProvider.isDark
            ? const Color(0xff161A1D)
            : AppColors.lightPrimary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(16))),
        actions: [
          /// Volume
          InkWell(
              onTap: () {
                setState(() {
                  isMute = !isMute;
                });
                saveMute();
              },
              child: isMute
                  ? Icon(
                      Icons.volume_up_outlined,
                      size: mqData!.size.width * 0.07,
                      color: themeProvider.isDark
                          ? AppColors.darkPrimary
                          : AppColors.lightTextSecondary,
                    )
                  : Icon(
                      Icons.volume_off_rounded,
                      size: mqData!.size.width * 0.07,
                      color: themeProvider.isDark
                          ? AppColors.darkPrimary
                          : AppColors.lightTextSecondary,
                    )),

          /// light and dark them
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return InkWell(
                  onTap: () {
                    themeProvider.toggleTheme();
                  },
                  child: Icon(
                    themeProvider.isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    size: mqData!.size.width * 0.07,
                    color: themeProvider.isDark
                        ? AppColors.darkPrimary
                        : AppColors.lightTextSecondary,
                  ),
                );
              },
            ),
          ),

          /// Share button
          IconButton(
            onPressed: () => MyDialogs.shareApp(context),
            icon: Icon(
              Icons.share,
              size: mqData!.size.width * 0.06,
              color: themeProvider.isDark
                  ? AppColors.darkPrimary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
      backgroundColor: themeProvider.isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,

      /// ---- body ---- ///
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// score card
            Container(
              margin: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                      width: 1, color: AppColors.secondary.withAlpha(110)),
                  left: BorderSide(
                      width: 1, color: AppColors.secondary.withAlpha(110)),
                  right: BorderSide(
                      width: 1, color: AppColors.secondary.withAlpha(110)),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Current Score with icon
                        _buildScoreCard(
                          context,
                          icon: Icons.star,
                          title: "Score",
                          value: score,
                          color: AppColors.darkPrimaryDark,
                        ),

                        // Max Score with icon
                        _buildScoreCard(
                          context,
                          icon: Icons.leaderboard,
                          title: "Max Score",
                          value: maxScore,
                          color: Colors.amber[700]!,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: mqData!.size.height * 0.05,
                    decoration: BoxDecoration(
                      color:
                          gameOver ? AppColors.lightError : AppColors.secondary,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      /// game ove then show this part
                      child: gameOver
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.warning_amber,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Game Over! Tap to Restart",
                                  style: myTextStyle18(
                                    context,
                                    fontColor: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              "Level $level",
                              style: myTextStyle24(
                                context,
                                fontColor: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: mqData!.size.height * 0.03,
            ),

            ///---------------BOX------------------///
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  /// grid view
                  GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: colors.length,
                    itemBuilder: (context, index) {
                      return buildButton(colors[index]);
                    },
                  ),

                  /// start button
                  GestureDetector(
                    onTap: started
                        ? null
                        : () {
                            startGame();
                            if (isMute) {
                              audioPlayer.play(AssetSource('audio/start.mp3'));
                            }
                          },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.lightPrimary.withAlpha(120),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: mqData!.size.height * 0.15,
                          width: mqData!.size.height * 0.15,
                          decoration: BoxDecoration(
                            color: started
                                ? Colors.grey[500]
                                : AppColors.darkPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              gameOver ? "Restart " : "START",
                              style: myTextStyle24(context,
                                  fontColor:
                                      started ? Colors.black45 : Colors.black,
                                  fontWeight: FontWeight.w900),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// -------------------- WIDGETS-----------------------///

  Widget buildButton(String color) {
    Color btnColor;
    BorderRadiusGeometry borderRadius;
    switch (color) {
      case "red":
        btnColor = Colors.red;
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(80),
          bottomRight: Radius.circular(20),
        );
        break;
      case "yellow":
        btnColor = Colors.yellow;
        borderRadius = const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(80),
        );
        break;
      case "green":
        btnColor = Colors.greenAccent;
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(80),
          bottomRight: Radius.circular(20),
        );
        break;
      case "blue":
        btnColor = Colors.blueAccent;
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(80),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        );
        break;
      default:
        btnColor = Colors.white;
        borderRadius = BorderRadius.circular(10);
    }

    return GestureDetector(
      onTap: () {
        if (started && !gameOver && userTurn) userPress(color);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: flashMap[color]! ? Colors.white : btnColor,
          borderRadius: borderRadius,
          border: Border.all(width: 2, color: btnColor),
          boxShadow: [
            BoxShadow(
                color: flashMap[color]! ? Colors.white : Colors.black,
                blurRadius: 1,
                spreadRadius: 0.5),
          ],
        ),
      ),
    );
  }

  // Helper widget for score cards
  Widget _buildScoreCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        SizedBox(height: 4),
        Text(
          title,
          style: myTextStyle18(context,
              fontColor: Colors.grey[600], fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 4),
        Text(
          "$value",
          style: myTextStyle24(context,
              fontColor: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
