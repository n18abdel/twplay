import 'package:flutter/material.dart';
import 'package:twitch_chat_render/models/chat_model.dart';
import 'package:twitch_chat_render/services/twitch_badges.dart';
import 'package:twitch_chat_render/widgets/chat_emote.dart';
import 'package:twitch_chat_render/widgets/chat_text_fragment.dart';
import 'package:twitch_chat_render/widgets/chat_user.dart';
import 'package:twitch_chat_render/widgets/utils.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({Key? key, this.streamer, this.badges, this.comment})
      : super(key: key);

  final Streamer? streamer;
  final TwitchBadges? badges;
  final Comment? comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Text.rich(
        TextSpan(children: <InlineSpan>[
          WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: ChatUser(badges: badges, comment: comment)),
          ...comment!.message!.fragments!.map((fragment) {
            return fragment.emoticon == null
                ? WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: ChatTextFragment(fragment: fragment.text!))
                : WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Utils.emoteWrapper(
                        context: context,
                        emote: ChatEmote(emoticon: fragment.emoticon)));
          }),
        ]),
      ),
    );
  }
}
