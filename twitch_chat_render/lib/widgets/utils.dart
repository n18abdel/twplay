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

  static CachedNetworkImage cachedNetworkImage(String url) {
    return CachedNetworkImage(
      placeholder: (context, url) => const CircularProgressIndicator(),
      imageUrl: url,
    );
  }

  static Tooltip tooltip(
      {required BuildContext context,
      required String url,
      required String name}) {
    return Tooltip(
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColorLight,
          borderRadius: const BorderRadius.all(Radius.circular(20))),
      richMessage: WidgetSpan(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            cachedNetworkImage(url.replaceRange(
                url.lastIndexOf("2"), url.lastIndexOf("2") + 1, "3")),
            Text(name)
          ],
        ),
      )),
      child: cachedNetworkImage(url),
    );
  }

  static WidgetSpan emoteWrapper(
      {required BuildContext context,
      required String url,
      required String name}) {
    return WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Container(
            margin: const EdgeInsets.only(top: 4),
            height: 1.5 * Utils.heightOfText(context: context),
            child: tooltip(context: context, name: name, url: url)));
  }
}
