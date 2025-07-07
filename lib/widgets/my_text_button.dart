import 'package:flutter/cupertino.dart';

import '../utils/custom_text_style.dart';

class MyTextButton extends StatelessWidget {
  VoidCallback onTap;
  Color btnRipColor;
  Color btnColor;
  Color textColor;
  Size size;
  String btnText;
  MyTextButton(
      {super.key,
      required this.onTap,
      required this.btnRipColor,
      required this.size,
      required this.btnColor,
      required this.btnText,
      required this.textColor});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      /// outer container
      child: Container(
        decoration: BoxDecoration(
            color: btnRipColor, borderRadius: BorderRadius.circular(8)),

        /// inside container
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: size.width,
            height: size.height * 0.05,
            decoration: BoxDecoration(
                color: btnColor, borderRadius: BorderRadius.circular(8)),
            child: Center(
              child: Text(
                btnText,
                style: myTextStyle24(context,
                    fontColor: textColor, fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
