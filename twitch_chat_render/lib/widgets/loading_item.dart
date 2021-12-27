import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:twitch_chat_render/widgets/utils.dart';

class LoadingItem extends StatelessWidget {
  const LoadingItem({Key? key, required this.text, required this.item})
      : super(key: key);
  final String text;
  final item;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(flex: 5, child: Text(text)),
        item == null || (item is! List && !item.initialized())
            ? Flexible(
                child: SpinKitCubeGrid(
                  size: Utils.heightOfText(context: context),
                  color: Theme.of(context).primaryColorLight,
                ),
              )
            : Flexible(
                child: Icon(
                  Icons.check,
                  size: Utils.heightOfText(context: context),
                ),
              )
      ],
    );
  }
}
