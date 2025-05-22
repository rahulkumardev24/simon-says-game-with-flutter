import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simon_say_game/utils/custom_text_style.dart';

class MyDialogs {
  static void MySnackBar(
    BuildContext context, {
    String? title,
    Color backGround = Colors.black38,
    Color fontColor = Colors.white70,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      title!,
      style: myTextStyle18(context, fontColor: fontColor),
    )));
  }

  static Future<void> shareApp(BuildContext context) async {
    final mqData = MediaQuery.of(context).size;
    const playStoreLink =
        "https://play.google.com/store/apps/details?id=com.appcreatorrahul.simonsay";
    try {
      final result = await SharePlus.instance.share(ShareParams(
        text:
            '🌟 Boost your memory & reflexes with this lightning-fast Simon Says game! Perfect for all ages!  🌟\n\n$playStoreLink',
        subject: 'Simon Says',
      ));

      if (result.status == ShareResultStatus.success) {
        // Show impressive thank you animation
        await showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.7),
          builder: (context) => Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: mqData.width * 0.85,
                height: mqData.height * 0.5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5)
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      "assets/animations/thank you.json",
                      width: mqData.width * 0.6,
                      height: mqData.height * 0.3,
                      repeat: false,
                    ),
                    const SizedBox(height: 20),
                    Text("Thank You for Sharing!",
                        style: myTextStyle18(context)),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Your support helps us grow and improve the app for everyone!",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Continue",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Sharing failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to share")),
      );
    }
  }
}
