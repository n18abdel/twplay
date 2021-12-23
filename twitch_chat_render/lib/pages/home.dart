import 'package:flutter/material.dart';
import 'package:twitch_chat_render/widgets/chat.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Chat(),
    );
  }
}
