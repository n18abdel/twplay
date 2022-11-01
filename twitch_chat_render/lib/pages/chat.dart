import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitch_chat_render/widgets/chat.dart';
import 'package:twitch_chat_render/widgets/custom_app_bar.dart';
import 'package:twitch_chat_render/widgets/resume_scrolling_button.dart';
import '../models/app_status.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        context.read<AppStatus>().stopScolling();
      },
      onHover: (event) {
        context.read<AppStatus>().hoverChat();
      },
      child: const SafeArea(
        child: Scaffold(
          appBar: CustomAppBar(),
          body: Chat(),
          floatingActionButton: ResumeScrollingButton(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }
}
