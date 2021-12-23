import 'package:flutter/material.dart';
import 'package:twitch_chat_render/models/chat_model.dart';
import 'package:twitch_chat_render/services/amqp_interface.dart';
import 'package:twitch_chat_render/widgets/chat_message.dart';

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

  @override
  Widget build(BuildContext context) {
    return init
        ? ListView.builder(
            itemCount: _maxMessageCount,
            itemBuilder: (BuildContext context, int index) {
              return ChatMessage(comment: comments?[0]);
            })
        : const Center(
            child: Text("Loading"),
          );
  }
}
