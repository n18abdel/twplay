import 'package:flutter/material.dart';
import 'package:twitch_chat_render/models/chat_model.dart';
import 'package:twitch_chat_render/services/bttv_emotes.dart';
import 'package:twitch_chat_render/widgets/utils.dart';

class ChatTextFragment {
  const ChatTextFragment({required this.fragment, this.streamer});

  final Streamer? streamer;
  final String fragment;

  List<String> tokenize(String fragment) {
    String leadingSpaces = RegExp(r'^\s*').stringMatch(fragment) ?? "";
    String trailingSpaces = RegExp(r'\s*$').stringMatch(fragment) ?? "";

    List<String> innerFragments = fragment.trim().split(RegExp('\\s+'));

    List<String> spaces = fragment.trim().split(RegExp('\\S+'));

    List<String> tokens = [leadingSpaces];
    for (var i = 0; i < innerFragments.length; i++) {
      tokens.addAll([spaces[i], innerFragments[i]]);
    }
    tokens.add(trailingSpaces);

    return tokens;
  }

  TextSpan from(BuildContext context) {
    List<String> tokens = tokenize(fragment);
    List<InlineSpan> spans = [];
    for (var token in tokens) {
      String? url = BTTVEmotes(streamer: streamer).getDownloadUrl(name: token);
      if (url == null) {
        spans.add(TextSpan(
            text: token,
            style: TextStyle(
                fontWeight: token.startsWith("@") ? FontWeight.bold : null)));
      } else {
        spans.add(Utils.emoteWrapper(context: context, url: url, name: token));
      }
    }
    return TextSpan(children: spans);
  }
}
