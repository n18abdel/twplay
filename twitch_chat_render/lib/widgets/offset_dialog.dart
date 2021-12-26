import 'package:flutter/material.dart';
import 'package:twitch_chat_render/services/app_status.dart';

class OffsetDialog extends StatelessWidget {
  const OffsetDialog({Key? key, required this.model}) : super(key: key);

  final AppStatus model;

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    onPressed: () {
                      model.decOffset();
                    },
                    icon: Icon(Icons.remove)),
                Text('Offset: ${model.offset}s'),
                IconButton(
                    onPressed: () {
                      model.incOffset();
                    },
                    icon: Icon(Icons.add)),
              ],
            ),
          ),
        ));
  }
}
