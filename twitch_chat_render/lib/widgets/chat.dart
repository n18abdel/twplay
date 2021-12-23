import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:twitch_chat_render/models/chat_model.dart';
import 'package:twitch_chat_render/services/amqp_interface.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final int _maxMessageCount = 200;
  late List<Comment>? comments;
  bool init = false;

  @override
  void initState() {
    super.initState();
    retrieveComments();
  }

  void retrieveComments() async {
    comments = ChatModel.fromJson(await AmqpInterface().retriveChat()).comments;
    setState(() {
      init = true;
    });
  }

  Widget getMessage(Comment? comment) {
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

  @override
  Widget build(BuildContext context) {
    return init
        ? ListView.builder(
            itemCount: _maxMessageCount,
            itemBuilder: (BuildContext context, int index) {
              return getMessage(comments?[0]);
            })
        : const Center(
            child: Text("Loading"),
          );
  }
}
