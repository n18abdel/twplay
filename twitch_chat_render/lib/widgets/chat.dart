import 'dart:async';

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
  int nextMessageIndex = 0;
  Duration updatePeriod = const Duration(milliseconds: 300);
  bool init = false;
  int? initTick;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    retrieveComments();
    Timer.periodic(updatePeriod, (Timer timer) {
      if (init) {
        initTick ??= timer.tick;
        setState(() {
          double currentTime =
              (timer.tick - initTick!) * updatePeriod.inMilliseconds / 1000;
          while (nextMessageIndex < comments!.length - 1 &&
              comments![nextMessageIndex].contentOffsetSeconds! < currentTime) {
            nextMessageIndex++;
          }
        });
      }
    });
  }

  void retrieveComments() async {
    comments = ChatModel.fromJson(await AmqpInterface().retriveChat()).comments;
    setState(() {
      init = true;
    });
  }

  List<Comment>? activeComments() {
    return comments?.sublist(
        (nextMessageIndex - _maxMessageCount) >= 0
            ? (nextMessageIndex - _maxMessageCount)
            : 0,
        nextMessageIndex);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
    return init
        ? ListView.builder(
            controller: scrollController,
            itemCount: activeComments()?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              return ChatMessage(comment: activeComments()?[index]);
            })
        : const Center(
            child: Text("Loading"),
          );
  }
}
