import 'package:flutter/material.dart';
import 'package:twitch_chat_render/widgets/chat.dart';
import 'package:twitch_chat_render/widgets/custom_app_bar.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(),
        body: Chat(),
      ),
    );
  }
}
