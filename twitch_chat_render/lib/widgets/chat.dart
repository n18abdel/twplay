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
  List<Comment>? comments;
  int nextMessageIndex = 0;
  Duration updatePeriod = const Duration(milliseconds: 300);
  Timer? timer;
  double chatTime = 0;
  bool playing = false;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    retrieveComments();
    setupSync();
  }

  void play(double playerPosition) {
    playing = true;
    timer = Timer.periodic(updatePeriod, (Timer timer) {
      if (comments != null) {
        setState(() {
          forwardMessageIndex(playerPosition);
        });
      }
    });
  }

  void pause(double playerPosition) {
    playing = false;
    timer?.cancel();
  }

  void adjustTimer(double playerPosition) {
    if (playing) {
      pause(playerPosition);
      play(playerPosition);
    } else {
      setState(() {
        forwardMessageIndex(playerPosition);
      });
    }
  }

  void seek(double playerPosition) {
    setState(() {
      bool wasPlaying = playing;
      if (wasPlaying) pause(playerPosition);
      if (playerPosition > chatTime) {
        forwardMessageIndex(playerPosition);
      } else {
        backwardMessageIndex(playerPosition);
      }
      if (wasPlaying) play(playerPosition);
    });
  }

  double elapsedTimerDuration() {
    return timer == null ? 0 : timer!.tick * updatePeriod.inMilliseconds / 1000;
  }

  void forwardMessageIndex(double playerPosition) {
    chatTime = playerPosition + elapsedTimerDuration();
    while (nextMessageIndex < comments!.length - 1 &&
        comments![nextMessageIndex].contentOffsetSeconds! < chatTime) {
      nextMessageIndex++;
    }
  }

  void backwardMessageIndex(double playerPosition) {
    chatTime = playerPosition + elapsedTimerDuration();
    while (nextMessageIndex > 0 &&
        comments![nextMessageIndex - 1].contentOffsetSeconds! > chatTime) {
      nextMessageIndex--;
    }
  }

  void retrieveComments() async {
    comments = ChatModel.fromJson(await AmqpInterface().retriveChat()).comments;
    setState(() {});
  }

  void setupSync() {
    AmqpInterface().setupSync(
        {"play": play, "pause": pause, "timer": adjustTimer, "seek": seek});
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
    return comments != null
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
