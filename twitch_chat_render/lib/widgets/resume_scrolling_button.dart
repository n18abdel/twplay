import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_status.dart';

class ResumeScrollingButton extends StatelessWidget {
  const ResumeScrollingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return context.select((AppStatus s) => s.shouldScroll)
        ? const SizedBox.shrink()
        : FloatingActionButton.extended(
            onPressed: context.read<AppStatus>().resumeScrolling,
            icon: const Icon(Icons.arrow_downward),
            label: const Text('Resume scrolling'));
  }
}
