import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:twitch_chat_render/models/chat_model.dart';
import 'package:twitch_chat_render/services/twitch_badges.dart';
import 'package:twitch_chat_render/widgets/chat_badge.dart';
import 'package:twitch_chat_render/widgets/utils.dart';

class ChatUser extends StatelessWidget {
  const ChatUser({Key? key, this.badges, this.comment}) : super(key: key);
  final TwitchBadges? badges;
  final Comment? comment;

  @override
  Widget build(BuildContext context) {
    Text username = Text("${comment?.commenter?.displayName}: ",
        style: TextStyle(
            color: comment?.message?.userColor == null
                ? Theme.of(context).primaryColorLight
                : HexColor(comment!.message!.userColor!),
            fontWeight: FontWeight.bold));
    return Text.rich(
      WidgetSpan(
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
          username
        ],
      )),
    );
  }
}
