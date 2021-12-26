import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitch_chat_render/services/app_status.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    Key? key,
  }) : super(key: key);

  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Consumer<AppStatus>(
      builder: (context, appStatus, child) {
        if (!appStatus.loaded) {
          return const Text("Loading");
        } else {
          return Column(
            children: [
              appStatus.playing
                  ? const Icon(Icons.play_arrow)
                  : const Icon(Icons.pause),
              Text(
                "Speed : ${appStatus.speed}",
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          );
        }
      },
    ));
  }
}
