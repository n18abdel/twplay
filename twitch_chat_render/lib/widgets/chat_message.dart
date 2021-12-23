import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:twitch_chat_render/models/chat_model.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({Key? key, this.comment}) : super(key: key);

  final Comment? comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text.rich(
        TextSpan(children: <InlineSpan>[
          TextSpan(
              text: "${comment?.commenter?.displayName}: ",
              style: TextStyle(
                  color: HexColor(comment?.message?.userColor ?? "#010101"),
                  fontWeight: FontWeight.bold)),
          TextSpan(text: comment?.message?.body),
        ]),
      ),
    );
  }
}
