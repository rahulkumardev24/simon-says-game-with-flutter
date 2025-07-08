import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simon_say_game/helper/colors.dart';
import 'package:simon_say_game/helper/my_dialogs.dart';
import 'package:simon_say_game/utils/custom_text_style.dart';
import 'package:simon_say_game/widgets/my_text_button.dart';
import '../../provider/them_provider.dart';
import '../../utils/app_utils.dart';
import '../../widgets/score_board_card.dart';

class TenBoxScreen extends StatefulWidget {
  @override
  _SimonSaysGameState createState() => _SimonSaysGameState();
}

class _SimonSaysGameState extends State<TenBoxScreen> {
  final String playStoreLink =
      "https://play.google.com/store/apps/details?id=com.appcreatorrahul.simonsay";
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
    "color8",
    "color9",
    "color10"
  ];
  bool started = false;
  int level = 0;
  bool userTurn = false;

  bool gameOver = false;
  int score = 0;
  int maxScore = 0;

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
    "color8": false,
    "color9": false,
    "color10": false
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
      maxScore = prefs.getInt('tenBoxMaxScore') ?? 0;
    });
  }

  /// Save max score to SharedPreferences
  void saveMaxScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tenBoxMaxScore', maxScore);
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

  Size? mqData;
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    mqData = MediaQuery.of(context).size;
    return Animate(
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
                        size: mqData!.width * 0.07,
                        color: themeProvider.isDark
                            ? AppColors.darkPrimary
                            : AppColors.lightTextSecondary,
                      )
                    : Icon(
                        Icons.volume_off_rounded,
                        size: mqData!.width * 0.07,
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
                      size: mqData!.width * 0.07,
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
                size: mqData!.width * 0.06,
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
              ScoreBoardCard(
                scoreValue: score,
                maxScore: maxScore,
                isGameOver: gameOver,
                level: level,
              ),

              SizedBox(
                height: mqData!.height * 0.03,
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
                        childAspectRatio: 5 / 2,
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
                      height: mqData!.height * 0.05,
                    ),

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
                        await Future.delayed(Duration(milliseconds: 800));
                        startGame();
                      },

                      btnRipColor: started
                          ? Colors.grey
                          : AppColors.lightPrimary.withAlpha(120),
                      size: mqData!,
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
          topLeft: Radius.circular(80),
          bottomLeft: Radius.circular(80),
        );
        break;
      case "yellow":
        btnColor = Colors.yellow;
        borderRadius = const BorderRadius.only(
          topRight: Radius.circular(80),
          bottomRight: Radius.circular(80),
        );
        break;
      case "green":
        btnColor = Colors.greenAccent;
        borderRadius = const BorderRadius.only(
          topRight: Radius.circular(80),
          bottomRight: Radius.circular(80),
        );
        break;
      case "blue":
        btnColor = Colors.blueAccent;
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(80),
          bottomLeft: Radius.circular(80),
        );
        break;

      case "orange":
        btnColor = Colors.orangeAccent;
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(80),
          bottomLeft: Radius.circular(80),
        );
        break;

      case "cyan":
        btnColor = Colors.cyanAccent;
        borderRadius = const BorderRadius.only(
          topRight: Radius.circular(80),
          bottomRight: Radius.circular(80),
        );
        break;

      case "color7":
        btnColor = Color(0xffab80c2);
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(80),
          bottomLeft: Radius.circular(80),
        );
        break;

      case "color8":
        btnColor = Color(0xfffb6f92);
        borderRadius = const BorderRadius.only(
          topRight: Radius.circular(80),
          bottomRight: Radius.circular(80),
        );
        break;

      case "color9":
        btnColor = Color(0xff14746f);
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(80),
          bottomLeft: Radius.circular(80),
        );
        break;

      case "color10":
        btnColor = Color(0xff3e5c76);
        borderRadius = const BorderRadius.only(
          topRight: Radius.circular(80),
          bottomRight: Radius.circular(80),
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
