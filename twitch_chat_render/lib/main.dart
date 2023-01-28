import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitch_chat_render/pages/chat.dart';
import 'package:twitch_chat_render/pages/ip_setup.dart';
import 'package:twitch_chat_render/pages/loading.dart';
import 'package:twitch_chat_render/models/app_status.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final bool mobileOS = Platform.isIOS || Platform.isAndroid;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppStatus(),
      child: MaterialApp(
        title: 'Twitch chat render',
        themeMode: ThemeMode.system,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        initialRoute: mobileOS ? "/setup" : "/loading",
        routes: {
          "/chat": (_) => const ChatPage(),
          "/loading": (_) => const LoadingPage(),
          "/setup": (_) => const IpSetupPage()
        },
      ),
    );
  }
}
