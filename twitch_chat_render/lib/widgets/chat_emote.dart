import 'package:flutter/material.dart';
import 'package:twitch_chat_render/widgets/utils.dart';

class ChatEmote {
  const ChatEmote({this.emoticon});

  final dynamic emoticon;

  WidgetSpan from(BuildContext context) {
    return Utils.emoteWrapper(
        context: context,
        url:
            'https://static-cdn.jtvnw.net/emoticons/v2/${emoticon["emoticon_id"]}/default/dark/2.0');
  }
}
