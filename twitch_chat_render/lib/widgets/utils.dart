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

  static CachedNetworkImage cachedNetworkImage(
      String url, BuildContext context) {
    return CachedNetworkImage(
      placeholder: (context, url) => SizedBox(
        height: Utils.heightOfText(context: context),
        width: Utils.heightOfText(context: context),
        child: const Placeholder(),
      ),
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
            cachedNetworkImage(
                url.replaceRange(
                    url.lastIndexOf("1"), url.lastIndexOf("1") + 1, "3"),
                context),
            Text(name)
          ],
        ),
      )),
      child: cachedNetworkImage(url, context),
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

  static String replaceReplyMention(BuildContext context, String fragment,
      {int? fragmentIndex, int? commentIndex, Comment? comment}) {
    if (fragmentIndex != 0 || comment?.replyParentMsgId == null) {
      return fragment;
    }
    List<Comment>? comments =
        Provider.of<AppStatus>(context, listen: false).comments;

    String? lastThreadUsername = comments
        ?.getRange(0, commentIndex!)
        .lastWhere((c) {
          return c.id == comment?.replyParentMsgId ||
              c.replyParentMsgId == comment?.replyParentMsgId &&
                  c.commenter?.displayName!.toLowerCase() !=
                      comment?.commenter?.displayName!.toLowerCase();
        })
        .commenter
        ?.displayName!
        .toLowerCase();
    if (lastThreadUsername == null) {
      return fragment;
    }
    return fragment.replaceFirst(RegExp(r'\S*'), "@$lastThreadUsername");
  }

  static TextButton clickableUsername(
      {required BuildContext context,
      required Text child,
      required String displayName}) {
    String lookupUsername = displayName.toLowerCase();
    return TextButton(
      style: TextButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.all(0),
        minimumSize: const Size(0, 0),
      ),
      onPressed: () {
        AppStatus appStatus = context.read<AppStatus>();
        Set<String> mentions = {};
        Iterable<Comment>? filteredComments = appStatus.comments
            ?.getRange(0, appStatus.nextMessageIndex)
            .toList()
            .reversed
            .where((c) {
          String? commentUsername = c.commenter?.displayName!.toLowerCase();
          bool isMention = mentions.contains(commentUsername);
          bool isLookupUsernameComment = commentUsername == lookupUsername;
          if (isLookupUsernameComment) {
            Iterable<String> newMentions = replaceReplyMention(
                    context, c.message!.body!,
                    comment: c,
                    fragmentIndex: 0,
                    commentIndex: appStatus.comments!.indexOf(c))
                .trim()
                .split(RegExp('\\s+'))
                .where((element) => element.startsWith("@"))
                .map((e) => e.replaceFirst("@", "").toLowerCase());
            mentions.addAll(newMentions);
          }
          return isLookupUsernameComment || isMention;
        }).toList();
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                contentPadding: const EdgeInsets.all(0),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                      reverse: true,
                      itemCount: filteredComments?.length,
                      itemBuilder: (context, index) {
                        Comment? c = filteredComments?.elementAt(index);
                        return ChatMessage(
                            streamer: appStatus.streamer,
                            badges: appStatus.badges,
                            index: appStatus.comments!.indexOf(c!),
                            comment: c);
                      }),
                ),
              );
            });
      },
      child: child,
    );
  }
}
