import 'package:flutter/material.dart';
import 'package:twitch_chat_render/models/chat_model.dart';
import 'package:twitch_chat_render/services/twitch_badges.dart';
import 'package:twitch_chat_render/widgets/chat_emote.dart';
import 'package:twitch_chat_render/widgets/chat_text_fragment.dart';
import 'package:twitch_chat_render/widgets/chat_user.dart';
import 'package:collection/collection.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage(
      {Key? key, this.streamer, this.badges, this.index, this.comment})
      : super(key: key);

  final Streamer? streamer;
  final TwitchBadges? badges;
  final int? index;
  final Comment? comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: comment!.message!.userNoticeParams?.msgId != null
            ? Colors.purple.withOpacity(0.5)
            : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: SelectableText.rich(
        TextSpan(children: <InlineSpan>[
          ChatUser(badges: badges, comment: comment).from(context),
          ...comment!.message!.fragments == null
              ? [
                  ChatTextFragment(
                          streamer: streamer, fragment: comment!.message!.body!)
                      .from(context)
                ]
              : comment!.message!.fragments!
                  .mapIndexed((fragmentIndex, fragment) {
                  return fragment.emoticon == null
                      ? ChatTextFragment(
                              streamer: streamer,
                              fragment: fragment.text!,
                              comment: comment,
                              commentIndex: index,
                              fragmentIndex: fragmentIndex)
                          .from(context)
                      : ChatEmote(
                              emoticon: fragment.emoticon, name: fragment.text!)
                          .from(context);
                }),
        ]),
      ),
    );
  }
}
