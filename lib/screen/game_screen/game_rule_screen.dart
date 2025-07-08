import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simon_say_game/helper/colors.dart';
import 'package:simon_say_game/utils/custom_text_style.dart';
import 'package:simon_say_game/widgets/my_text_button.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../provider/them_provider.dart';

class GameRulesScreen extends StatelessWidget {
  const GameRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;
    final isDarkMode = themeProvider.isDark;
    return Scaffold(
      /// ----  App bar --- ///
      appBar: AppBar(
        /// title
        title: Text(
          "Game Rule",
          style: myTextStyle24(
            context,
            fontColor: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: themeProvider.isDark
            ? AppColors.darkCardBackground
            : AppColors.lightPrimary,
      ),
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// header
            VxArc(
              height: size.height * 0.03,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.darkCardBackground
                      : AppColors.lightPrimary,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Simon Says Memory Game",
                        style: myTextStyle20(
                          context,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Remember and repeat the pattern to win!",
                        style: myTextStyle16(
                          context,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                children: [
                  // Rules list
                  ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      _buildRuleItem(
                        context,
                        icon: Icons.flag,
                        isDarkMode: isDarkMode,
                        title: "Objective",
                        description:
                            "Repeat the pattern shown by the game. Each correct repetition adds a new color.",
                      ),
                      _buildRuleItem(
                        context,
                        icon: Icons.touch_app,
                        isDarkMode: isDarkMode,
                        title: "How to Play",
                        description:
                            "1. Press START\n2. Watch the sequence\n3. Tap the boxes in order\n4. Each level adds a step\n5. Game ends if wrong",
                      ),
                      _buildRuleItem(
                        context,
                        icon: Icons.layers,
                        isDarkMode: isDarkMode,
                        title: "Game Modes",
                        description:
                            "• 4 Boxes - Easy\n• 6 Boxes - Medium\n• 8 Boxes - Hard\n• 10 Boxes - Expert",
                      ),
                      _buildRuleItem(
                        context,
                        icon: Icons.star,
                        isDarkMode: isDarkMode,
                        title: "Scoring",
                        description:
                            "• Level 1: 0 pts\n• Levels 2-3: +2\n• Levels 4-6: +5\n• Levels 7-10: +10\n• 10+: +20 pts",
                      ),
                      _buildRuleItem(
                        context,
                        icon: Icons.lightbulb,
                        isDarkMode: isDarkMode,
                        title: "Tips",
                        description:
                            "• Focus on colors & sounds\n• Take your time\n• Be accurate\n• Use headphones",
                      ),
                    ],
                  ),

                  /// Play button
                  MyTextButton(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      btnRipColor: AppColors.lightPrimaryLight,
                      size: size,
                      btnColor: AppColors.darkPrimary,
                      btnText: "Start Playing",
                      textColor: AppColors.darkTextPrimary)
                ],
              ),
            ),

            SizedBox(
              height: size.height * 0.02,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(BuildContext context,
      {required IconData icon,
      required String title,
      required String description,
      required bool isDarkMode}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.darkCardBackground.withAlpha(60)
            : AppColors.darkBackground.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Icons
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDarkMode
                  ? AppColors.darkPrimary
                  : AppColors.lightPrimaryLight,
            ),
            child: Icon(
              icon,
              size:MediaQuery.of(context).size.width * 0.06
              ,
              color: isDarkMode
                  ? AppColors.darkIconSecondary
                  : AppColors.lightIconSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// title
                Text(
                  title,
                  style: myTextStyle18(context,
                      fontWeight: FontWeight.bold,
                      fontColor: AppColors.lightPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: myTextStyle16(
                    context,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
