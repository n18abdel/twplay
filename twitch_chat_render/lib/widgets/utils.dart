import 'package:cached_network_image/cached_network_image.dart';
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

  static WidgetSpan emoteWrapper(
      {required BuildContext context, required String url}) {
    return WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Container(
            margin: const EdgeInsets.only(top: 4),
            height: 1.5 * Utils.heightOfText(context: context),
            child: CachedNetworkImage(
              placeholder: (context, url) => const CircularProgressIndicator(),
              imageUrl: url,
            )));
  }
}
