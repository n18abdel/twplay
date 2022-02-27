import 'package:flutter/material.dart';
import 'package:twitch_chat_render/models/app_status.dart';

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
                    icon: const Icon(Icons.remove)),
                const Text('Offset:'),
                SizedBox(
                  width: 50,
                  child: TextField(
                    onChanged: (text) {
                      model.setOffset(double.parse(text));
                    },
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      hintText: '${model.offset}',
                    ),
                  ),
                ),
                const Text('s'),
                IconButton(
                    onPressed: () {
                      model.incOffset();
                    },
                    icon: const Icon(Icons.add)),
              ],
            ),
          ),
        ));
  }
}
