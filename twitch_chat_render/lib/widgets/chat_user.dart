import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:twitch_chat_render/models/chat_model.dart';
import 'package:twitch_chat_render/services/twitch_badges.dart';
import 'package:twitch_chat_render/widgets/chat_badge.dart';
import 'package:twitch_chat_render/widgets/utils.dart';

class ChatUser {
  const ChatUser({this.badges, this.comment});
  final TwitchBadges? badges;
  final Comment? comment;

  WidgetSpan from(BuildContext context) {
    Text username = Text("${comment?.commenter?.displayName}: ",
        style: TextStyle(
            color: comment?.message?.userColor == null
                ? Color(comment!.commenter!.displayName!.hashCode).withAlpha(
                    255 -
                        Theme.of(context)
                            .backgroundColor
                            .computeLuminance()
                            .round())
                : HexColor(comment!.message!.userColor!),
            fontWeight: FontWeight.bold));
    return WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Wrap(
          spacing: 4,
          children: [
            ...comment?.message?.userBadges == null
                ? []
                : comment?.message?.userBadges!.map((badge) {
                    return SizedBox(
                        height: Utils.heightOfText(context: context),
                        child: ChatBadge(badge: badge, badges: badges));
                  }),
            Utils.clickableUsername(
                child: username,
                context: context,
                displayName: comment!.commenter!.displayName!)
          ],
        ));
  }
}
