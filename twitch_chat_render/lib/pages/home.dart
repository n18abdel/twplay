import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitch_chat_render/services/app_status.dart';
import 'package:twitch_chat_render/widgets/chat.dart';
import 'package:twitch_chat_render/widgets/custom_app_bar.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppStatus(),
      child: const Scaffold(
        appBar: CustomAppBar(),
        body: Chat(),
      ),
    );
  }
}
