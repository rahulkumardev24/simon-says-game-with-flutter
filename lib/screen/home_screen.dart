import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simon_say_game/utils/custom_text_style.dart';

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
  bool isLight = true ;

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

    if(isMute) audioPlayer.play(AssetSource('audio/tap.mp3'));

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
   if(isMute)  audioPlayer.play(AssetSource("audio/over.mp3"));
    setState(() {
      gameOver = true;
      started = false;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        gameSeq.clear();
        userSeq.clear();
        gameOver = false;
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
  void  saveMute() async {
    SharedPreferences preferences =  await SharedPreferences.getInstance() ;
    await preferences.setBool("checkMute", isMute) ;
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
    mqData = MediaQuery.of(context);
    return Scaffold(
      /// --------------------APPBAR------------------------///
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset("assets/icon/logo.png"),
        ),
        title: Text(
          "Simon says",
          style: myTextStyle24(),
        ),
        centerTitle: true,
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
                    )
                  : const Icon(
                      Icons.volume_off_rounded,
                      size: 30,
                    )) ,
          /// light and dark
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: InkWell(
                onTap: () {
                  setState(() {
                    isLight = !isLight;
                  });
                },
                child: isLight
                    ? const Icon(
                        Icons.light_mode_rounded,
                        size: 30,
                  color: Colors.orange,
                      )
                    : const Icon(
                        Icons.dark_mode_rounded,
                        size: 30,
                  color: Colors.blueAccent,
                      )),
          ) ,
        ],
      ),
      backgroundColor: gameOver ? Colors.red : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              gameOver
                  ? "Game Over! Tap to Restart"
                  : "Simon Says - Level $level",
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 20),

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

            const SizedBox(height: 30),
            Text(
              "Score: $score", // Show the updated score
              style: myTextStyle24(),
            ),
            Text(
              "Max Score: $maxScore", // Show the updated score
              style: myTextStyle18(),
            ),
            /// -------------------- Game Start ----------------------------///
            SizedBox(
           width: mqData!.size.width * 0.8,
              child: ElevatedButton(
                onPressed: started
                    ? null
                    : () {
                        startGame();
                       if(isMute) audioPlayer.play(AssetSource('audio/start.mp3'));
                      },
                style: ElevatedButton.styleFrom(

                  backgroundColor: started
                      ? Colors.grey
                      : Colors.blue, // Change color when disabled
                  padding: const EdgeInsets.symmetric(vertical: 6)
                ),
                child: Text("Start Game" , style: myTextStyle24(fontFamily: "secondary"),),
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
