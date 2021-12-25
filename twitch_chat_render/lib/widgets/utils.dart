import 'package:flutter/material.dart';

class Utils {
  static double heightOfText({required BuildContext context}) {
    return (TextPainter(
            text: const TextSpan(text: ""),
            maxLines: 1,
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            textDirection: TextDirection.ltr)
          ..layout())
        .size
        .height;
  }

  static Widget emoteWrapper(
      {required BuildContext context, required Widget emote}) {
    return Container(
        margin: const EdgeInsets.only(top: 4),
        height: 1.5 * Utils.heightOfText(context: context),
        child: emote);
  }
}
