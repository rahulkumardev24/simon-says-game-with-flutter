import 'package:flutter/material.dart';
import 'package:simon_say_game/utils/custom_text_style.dart';
import 'package:simon_say_game/helper/colors.dart';

class ScoreBoardCard extends StatelessWidget {
  final int scoreValue;

  final int maxScore;

  final bool isGameOver;
  final int level;

  const ScoreBoardCard({
    Key? key,
    required this.scoreValue,
    required this.maxScore,
    required this.isGameOver,
    required this.level,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(width: 1, color: AppColors.secondary.withAlpha(110)),
          left: BorderSide(width: 1, color: AppColors.secondary.withAlpha(110)),
          right:
          BorderSide(width: 1, color: AppColors.secondary.withAlpha(110)),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildColumn(Icons.star, "Score", scoreValue, AppColors.darkPrimaryDark, context),
                _buildColumn(Icons.leaderboard, "Max Score", maxScore, Colors.amber[700]!, context),
              ],
            ),
          ),
          Container(
            height: height * 0.05,
            decoration: BoxDecoration(
              color: isGameOver ? AppColors.lightError : AppColors.secondary,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Center(
              child: isGameOver
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Game Over! Tap to Restart",
                    style: myTextStyle18(context,
                        fontColor: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              )
                  : Text(
                "Level $level",
                style: myTextStyle24(context,
                    fontColor: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumn(
      IconData icon,
      String title,
      int value,
      Color color,
      BuildContext context,
      ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        SizedBox(height: 4),
        Text(
          title,
          style: myTextStyle18(
            context,
            fontColor: Colors.grey[600],
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "$value",
          style: myTextStyle24(
            context,
            fontColor: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
