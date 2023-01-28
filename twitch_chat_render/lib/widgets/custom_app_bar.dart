import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitch_chat_render/models/app_status.dart';
import 'package:twitch_chat_render/widgets/offset_dialog.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    Key? key,
  }) : super(key: key);

  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);

  List<Widget> getOptionnalsFields(BuildContext context, AppStatus appStatus) {
    List<Widget> optionnals = [];
    if (appStatus.speed != 1) {
      optionnals.add(Text(
        "Speed : ${appStatus.speed}",
        style: Theme.of(context).textTheme.bodySmall,
      ));
    }
    if (appStatus.offset != 0) {
      optionnals.add(Text(
        "Offset : ${appStatus.offset}s",
        style: Theme.of(context).textTheme.bodySmall,
      ));
    }
    return optionnals;
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Consumer<AppStatus>(
      builder: (context, appStatus, child) {
        return Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (_) {
                        return ChangeNotifierProvider.value(
                            value: appStatus,
                            child: Consumer<AppStatus>(
                                builder: (context, model, child) =>
                                    OffsetDialog(model: model)));
                      });
                },
                icon: const Icon(Icons.menu)),
            Center(
              child: Column(
                children: [
                  appStatus.playing
                      ? const Icon(Icons.play_arrow)
                      : const Icon(Icons.pause),
                  ...getOptionnalsFields(context, appStatus),
                ],
              ),
            )
          ],
        );
      },
    ));
  }
}
