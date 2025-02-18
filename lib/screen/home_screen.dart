import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simon_say_game/utils/custom_text_style.dart';

import '../provider/them_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _SimonSaysGameState createState() => _SimonSaysGameState();
}

class _SimonSaysGameState extends State<HomeScreen> {
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
        title: Text(
          "Simon says",
          style: myTextStyle24(context,
              fontColor: Colors.white, fontFamily: "secondary"),
        ),
        backgroundColor: themeProvider.isDark
            ? const Color(0xff161A1D)
            : const Color(0xff5E4DB2),
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
                  ? const Icon(
                      Icons.volume_up_outlined,
                      size: 30,
                      color: Colors.white70,
                    )
                  : const Icon(
                      Icons.volume_off_rounded,
                      size: 30,
                      color: Colors.white70,
                    )),

          /// light and dark them
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                    size: 30, // Adjust the size if needed
                    color: themeProvider.isDark
                        ? const Color(0xff5E4DB2)
                        : Colors.orange,
                  ),
                );
              },
            ),
          )
        ],
      ),
      backgroundColor: themeProvider.isDark
          ? const Color(0xff161A1D)
          : const Color(0xffe4d9ff),
      // backgroundColor: gameOver ? Colors.red : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Score: $score", // Show the updated score
                    style: myTextStyle24(context),
                  ),
                  Text(
                    "Max Score: $maxScore",
                    style: myTextStyle24(context),
                  ),
                ],
              ),
            ),
            gameOver
                ? Text(
                    "Game over plz Restart",
                    style: myTextStyle24(context,
                        fontColor: Colors.red, fontFamily: "secondary"),
                  )
                : Container(
                    width: mqData!.size.width * 0.9,
                    height: mqData!.size.height * 0.05,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadiusDirectional.only(
                            topEnd: Radius.circular(2),
                            topStart: Radius.circular(2),
                            bottomEnd: Radius.circular(20),
                            bottomStart: Radius.circular(20)),
                        color: Color(0xffB8ACF6)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// --------- level----------------------///
                        Text(
                          "Leve $level",
                          style: myTextStyle24(context),
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
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: colors.length,
                itemBuilder: (context, index) {
                  return buildButton(colors[index]);
                },
              ),
            ),

            SizedBox(
              height: mqData!.size.height * 0.03,
            ),

            /// -------------------- Game Start ----------------------------///
            SizedBox(
              width: mqData!.size.width * 0.9,
              child: ElevatedButton(
                onPressed: started
                    ? null
                    : () {
                        startGame();
                        if (isMute) {
                          audioPlayer.play(AssetSource('audio/start.mp3'));
                        }
                      },
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        started ? Colors.grey : const Color(0xff5E4DB2),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadiusDirectional.only(
                            topEnd: Radius.circular(20),
                            topStart: Radius.circular(20),
                            bottomEnd: Radius.circular(2),
                            bottomStart: Radius.circular(2))),
                    padding: const EdgeInsets.symmetric(vertical: 6)),
                child: Text(
                  "Start Game",
                  style: myTextStyle24(context, fontColor: Colors.white70),
                ),
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
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(100),
          bottomRight: Radius.circular(20),
        );
        break;
      case "yellow":
        btnColor = Colors.yellow;
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(100),
        );
        break;
      case "green":
        btnColor = Colors.greenAccent;
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(100),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(20),
        );
        break;
      case "blue":
        btnColor = Colors.blueAccent;
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(100),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(10),
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
}
