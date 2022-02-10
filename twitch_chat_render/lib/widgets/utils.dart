import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitch_chat_render/models/app_status.dart';
import 'package:twitch_chat_render/models/chat_model.dart';
import 'package:twitch_chat_render/widgets/chat_message.dart';

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
                url.lastIndexOf("1"), url.lastIndexOf("1") + 1, "3")),
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

  static TextButton clickableUsername(
      {required BuildContext context,
      required Text child,
      required String displayName}) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(0),
        minimumSize: const Size(0, 0),
      ),
      onPressed: () {
        AppStatus appStatus = context.read<AppStatus>();
        Iterable<Comment>? filteredComments = appStatus.comments
            ?.getRange(0, appStatus.nextMessageIndex)
            .where((c) {
              return c.commenter?.displayName!.toLowerCase() ==
                  displayName.toLowerCase();
            })
            .toList()
            .reversed;
        ScrollController listScrollController = ScrollController();
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                contentPadding: const EdgeInsets.all(0),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                      reverse: true,
                      controller: listScrollController,
                      itemCount: filteredComments?.length,
                      itemBuilder: (context, index) {
                        return ChatMessage(
                            streamer: appStatus.streamer,
                            badges: appStatus.badges,
                            comment: filteredComments?.elementAt(index));
                      }),
                ),
              );
            });
      },
      child: child,
    );
  }
}
