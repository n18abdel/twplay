import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitch_chat_render/models/app_status.dart';
import 'package:twitch_chat_render/widgets/loading_item.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  late final AppStatus myProvider;

  void myCallback() {
    if (context.read<AppStatus>().loaded()) {
      Navigator.pushReplacementNamed(context, "/chat")
          .then((_) => myProvider.exitLoadingPage());
    }
  }

  @override
  void initState() {
    super.initState();
    myProvider = Provider.of<AppStatus>(context, listen: false);
    myProvider.addListener(myCallback);
    myProvider.fetchChat();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LoadingItem(
                    text: "Fetching Chat",
                    item: context.select((AppStatus s) => s.comments)),
                LoadingItem(
                    text: "Fetching Badges",
                    item: context.select((AppStatus s) => s.badges)),
                LoadingItem(
                    text: "Fetching BTTV emotes",
                    item: context.select((AppStatus s) => s.bttvEmotes)),
                LoadingItem(
                    text: "Fetching 7TV emotes",
                    item: context.select((AppStatus s) => s.stvEmotes)),
                LoadingItem(
                    text: "Fetching Cheers emotes",
                    item: context.select((AppStatus s) => s.cheerEmotes)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    myProvider.removeListener(myCallback);
    super.dispose();
  }
}
