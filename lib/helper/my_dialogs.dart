import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simon_say_game/helper/app_constant.dart';
import 'package:simon_say_game/helper/colors.dart';
import 'package:simon_say_game/utils/custom_text_style.dart';
import '../provider/them_provider.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final mqData = MediaQuery.of(context).size;
    try {
      final result = await SharePlus.instance.share(ShareParams(
        text:
            'Boost your memory & reflexes with this lightning-fast Simon Says game! Download now :\n${AppConstant.playStoreLink}',
        subject: 'Simon Says',
      ));
      if (result.status == ShareResultStatus.success) {
        /// Show impressive thank you animation
        await showDialog(
          context: context,
          barrierColor: Colors.black26,
          builder: (context) => Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: mqData.width * 0.85,
                height: mqData.height * 0.5,
                decoration: BoxDecoration(
                  color: themeProvider.isDark
                      ? AppColors.darkBackground
                      : AppColors.lightPrimaryLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Lottie.asset(
                        alignment: Alignment.center,
                        "assets/animations/thank you.json",
                        height: mqData.width * 0.6,
                        fit: BoxFit.fill,
                        repeat: true,
                      ),
                    ),
                    Text("Thank You for Sharing!",
                        style: myTextStyle18(context,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Your support helps us grow and improve the app for everyone!",
                        textAlign: TextAlign.center,
                        style: myTextStyle15(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Spacer(),

                    /// --- Elevated button --- ///
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeProvider.isDark
                            ? AppColors.darkPrimary
                            : AppColors.lightPrimaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Continue",
                        style: myTextStyle18(context,
                            fontWeight: FontWeight.bold,
                            fontColor: Colors.black),
                      ),
                    ),
                    SizedBox(
                      height: mqData.height * 0.01,
                    )
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
