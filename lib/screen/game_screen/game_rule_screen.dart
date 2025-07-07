import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simon_say_game/helper/colors.dart';
import 'package:simon_say_game/utils/custom_text_style.dart';
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
            ? const Color(0xff161A1D)
            : AppColors.lightPrimary,
      ),
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            VxArc(
              height: 20,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightPrimary,
                  border: Border.all(
                      color: AppColors.lightPrimary.withOpacity(0.3)),
                ),
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
            const SizedBox(height: 24),

            // Rules list
            ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildRuleItem(
                  context,
                  icon: Icons.flag,
                  title: "Objective",
                  description:
                      "Repeat the pattern shown by the game. Each correct repetition adds a new color.",
                ),
                _buildRuleItem(
                  context,
                  icon: Icons.touch_app,
                  title: "How to Play",
                  description:
                      "1. Press START\n2. Watch the sequence\n3. Tap the boxes in order\n4. Each level adds a step\n5. Game ends if wrong",
                ),
                _buildRuleItem(
                  context,
                  icon: Icons.layers,
                  title: "Game Modes",
                  description:
                      "• 4 Boxes - Easy\n• 6 Boxes - Medium\n• 8 Boxes - Hard\n• 10 Boxes - Expert",
                ),
                _buildRuleItem(
                  context,
                  icon: Icons.star,
                  title: "Scoring",
                  description:
                      "• Level 1: 0 pts\n• Levels 2-3: +2\n• Levels 4-6: +5\n• Levels 7-10: +10\n• 10+: +20 pts",
                ),
                _buildRuleItem(
                  context,
                  icon: Icons.lightbulb,
                  title: "Tips",
                  description:
                      "• Focus on colors & sounds\n• Take your time\n• Be accurate\n• Use headphones",
                ),
              ],
            ),

            // Play button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Start Playing",
                  style: myTextStyle18(context,
                      fontColor: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: myTextStyle18(
                    context,
                    fontWeight: FontWeight.bold,
                  ),
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
