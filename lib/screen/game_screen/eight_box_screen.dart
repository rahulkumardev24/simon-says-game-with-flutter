import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:simon_say_game/helper/colors.dart';
import 'package:simon_say_game/utils/custom_text_style.dart';
import '../../provider/them_provider.dart';
import '../../utils/app_utils.dart';
import '../../widgets/my_text_button.dart';
import '../../widgets/score_board_card.dart';

class EightBoxScreen extends StatefulWidget {
  @override
  _SimonSaysGameState createState() => _SimonSaysGameState();
}

class _SimonSaysGameState extends State<EightBoxScreen> {
  List<String> gameSeq = [];
  List<String> userSeq = [];
  List<String> colors = [
    "blue",
    "green",
    "red",
    "yellow",
    "orange",
    "cyan",
    "color7",
    "color8"
  ];
  bool started = false;
  int level = 0;
  bool userTurn = false;

  bool gameOver = false;
  int score = 0;
  int _maxScore = 0;

  bool isMute = true;
  bool isLight = true;
  bool isVibrate = true;

  Map<String, bool> flashMap = {
    "red": false,
    "yellow": false,
    "green": false,
    "blue": false,
    "orange": false,
    "cyan": false,
    "color7": false,
    "color8": false
  };

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    int loadedScore = await AppUtils.loadMaxScore(key: "eightBoxMaxScore");
    bool loadMute = await AppUtils.loadMute();
    bool loadVibrate = await AppUtils.loadVibration();
    setState(() {
      _maxScore = loadedScore;
      isMute = loadMute;
      isVibrate = loadVibrate;
    });
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
    if (score > _maxScore) {
      _maxScore = score;
    }

    /// call the function to save the max score into shared preference
    AppUtils.saveMaxScore(score: score, key: "eightBoxMaxScore");

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
      await Future.delayed(const Duration(milliseconds: 300));

      // Play sound for computer flash
      AppUtils.playSound(fileName: "audio/tap.mp3", isMute: isMute);

      // Vibrate for computer flash
      AppUtils.playVibration(isVibrate: isVibrate, durationMs: 100);

      // Flash the box
      setState(() {
        flashMap[color] = true;
      });

      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        flashMap[color] = false;
      });
    }

    // Allow user to start playing
    setState(() {
      userTurn = true;
    });
  }

  /// user press functions
  bool isProcessingTap = false;

  /// user press functions
  void userPress(String color) {
    if (!userTurn || isProcessingTap) return;

    isProcessingTap = true;

    AppUtils.playSound(fileName: "audio/tap.mp3", isMute: isMute);
    AppUtils.playVibration(isVibrate: isVibrate);

    setState(() {
      userSeq.add(color);
      flashMap[color] = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        flashMap[color] = false;
      });

      checkAnswer(userSeq.length - 1);
      isProcessingTap = false;
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
    AppUtils.playSound(fileName: "audio/over.mp3", isMute: isMute);
    AppUtils.playVibration(isVibrate: isVibrate, durationMs: 400);
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

  Size? size;
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    size = MediaQuery.of(context).size;
    return SafeArea(
      child: Animate(
        effects: [
          SlideEffect(
              duration: 1200.milliseconds,
              delay: 100.ms,
              curve: Curves.easeOutExpo)
        ],
        child: Scaffold(
          /// --------------------APPBAR------------------------///
          appBar: AppBar(
            /// title
            title: Text(
              "Simon says",
              style: myTextStyle24(context,
                  fontColor: Colors.white, fontFamily: "secondary"),
            ),
            backgroundColor: themeProvider.isDark
                ? AppColors.darkCardBackground
                : AppColors.lightPrimary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16))),
            centerTitle: true,
          ),
          backgroundColor: themeProvider.isDark
              ? AppColors.darkBackground
              : AppColors.lightBackground,

          /// ---- body ---- ///
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: size!.height * 0.02,
                  ),
              
                  /// score card
                  ScoreBoardCard(
                    scoreValue: score,
                    maxScore: _maxScore,
                    isGameOver: gameOver,
                    level: level,
                  ),
              
                  SizedBox(
                    height: size!.height * 0.02,
                  ),
              
                  ///---------------BOX------------------///
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        /// grid view
                        GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            childAspectRatio: 5 / 2.5,
                            mainAxisSpacing: 8,
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: colors.length,
                          itemBuilder: (context, index) {
                            return Animate(effects: [
                              ScaleEffect(
                                duration: 500.milliseconds,
                                delay: (50 * index).ms,
                                curve: Curves.easeInSine,
                              ),
                            ], child: buildButton(colors[index]));
                          },
                        ),
              
                        SizedBox(
                          height: size!.height * 0.02,
                        ),
              
                        /// start button
                        MyTextButton(
                          onTap: started
                              ? () {}
                              : () async {
                                  AppUtils.playSound(
                                    fileName: "audio/start.mp3",
                                    isMute: isMute,
                                  );
                                  AppUtils.playVibration(
                                    isVibrate: isVibrate,
                                    durationMs: 400,
                                  );
                                  await Future.delayed(
                                      Duration(milliseconds: 800));
                                  startGame();
                                },
                          btnRipColor: started
                              ? Colors.grey
                              : AppColors.lightPrimary.withAlpha(120),
                          size: size!,
                          btnColor: started ? Colors.grey : AppColors.darkPrimary,
                          btnText: gameOver ? "Restart " : "START",
                          textColor: started ? Colors.black45 : Colors.black,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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
            bottomRight: Radius.circular(80),
            topRight: Radius.circular(20));
        break;
      case "yellow":
        btnColor = Colors.yellow;
        borderRadius = const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(80),
            bottomRight: Radius.circular(80),
            topRight: Radius.circular(20));
        break;
      case "green":
        btnColor = Colors.greenAccent;
        borderRadius = const BorderRadius.only(
            topLeft: Radius.circular(80),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
            topRight: Radius.circular(80));
        break;
      case "blue":
        btnColor = Colors.blueAccent;
        borderRadius = const BorderRadius.only(
            topLeft: Radius.circular(80),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
            topRight: Radius.circular(80));
        break;

      case "orange":
        btnColor = Colors.orangeAccent;
        borderRadius = const BorderRadius.only(
            topLeft: Radius.circular(80),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
            topRight: Radius.circular(80));
        break;

      case "cyan":
        btnColor = Colors.cyanAccent;
        borderRadius = const BorderRadius.only(
            topLeft: Radius.circular(80),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
            topRight: Radius.circular(80));
        break;

      case "color7":
        btnColor = Color(0xffab80c2);
        borderRadius = const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(80),
            bottomRight: Radius.circular(80),
            topRight: Radius.circular(20));
        break;

      case "color8":
        btnColor = Color(0xfffb6f92);
        borderRadius = const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(80),
            bottomRight: Radius.circular(80),
            topRight: Radius.circular(20));
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
        duration: const Duration(milliseconds: 200),
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
}
