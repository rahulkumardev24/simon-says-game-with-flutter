import 'package:flutter/material.dart';

import '../helper/colors.dart';

@immutable
class MyIconButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final backgroundColor ;
  final double iconSize;
  final VoidCallback onTap;

  const MyIconButton({
    super.key,
    required this.icon,
    this.iconColor = AppColors.lightIconPrimary,
    this.iconSize = 23.0,
    required this.onTap,
    required this.backgroundColor
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onTap,
        child: Container(
            decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(200)),

            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child:
                  Center(child: Icon(icon, color: iconColor, size: iconSize)),
            )),
      ),
    );
  }
}
