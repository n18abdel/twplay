import 'dart:math';

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
    double backgroundLuminance =
        Theme.of(context).colorScheme.background.computeLuminance();
    Color baseColor = comment?.message?.userColor == null
        ? Color(comment!.commenter!.displayName!.hashCode)
        : HexColor(comment!.message!.userColor!);
    int offset = backgroundLuminance < 0.5
        ? [255 - baseColor.red, 255 - baseColor.green, 255 - baseColor.blue]
            .reduce(min)
        : [-baseColor.red, -baseColor.green, -baseColor.blue].reduce(max);
    Text username = Text("${comment?.commenter?.displayName}: ",
        style: TextStyle(
            color: Color.fromARGB(255, baseColor.red + offset,
                baseColor.green + offset, baseColor.blue + offset),
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
