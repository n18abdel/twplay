import 'package:flutter/material.dart';
import 'package:twitch_chat_render/widgets/utils.dart';

class ChatEmote {
  const ChatEmote({required this.name, this.emoticon});

  final dynamic emoticon;
  final String name;

  WidgetSpan from(BuildContext context) {
    return Utils.emoteWrapper(
        context: context,
        name: name,
        url:
            'https://static-cdn.jtvnw.net/emoticons/v2/${emoticon["emoticon_id"]}/default/dark/1.0');
  }
}
