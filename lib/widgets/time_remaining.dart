import 'dart:async';

import 'package:dash_tools/common/extensions.dart';
import 'package:dash_tools/previews.dart';
import 'package:flutter/material.dart';

class TimeRemaining extends StatefulWidget {
  /// Duration time, it is the remaining time for the counter to reach 0
  final Duration duration;

  /// It is called when the counter reaches 0
  final VoidCallback? onTimeOver;

  final String Function(String duration) text;

  const TimeRemaining({
    super.key,
    required this.duration,
    this.onTimeOver,
    required this.text,
  });

  @override
  State<TimeRemaining> createState() => _TimeRemainingState();
}

class _TimeRemainingState extends State<TimeRemaining> {
  late Timer timer;
  late DateTime datetime;
  late String text;

  @override
  void initState() {
    _initTimer();
    super.initState();
  }

  /// Initialize the timer
  void _initTimer() {
    datetime = DateTime.now().add(widget.duration);
    text = Duration.zero.humanize;

    if (mounted) {
      timer = Timer.periodic(const Duration(milliseconds: 200), (Timer timer) {
        if (DateTime.now().isBefore(datetime)) {
          Duration difference = datetime.difference(DateTime.now());
          if (mounted) {
            setState(() {
              text = difference.humanize;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              text = Duration.zero.humanize;
            });
          }
          timer.cancel();
          widget.onTimeOver?.call();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant TimeRemaining oldWidget) {
    if (oldWidget.duration != widget.duration) {
      try {
        if (timer.isActive) {
          timer.cancel();
        }
      } catch (_) {}

      _initTimer();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(widget.text(text));
  }
}

@MultiBrightnessPreview(name: 'TimeRemaining')
Widget timeRemainingPreview() => TimeRemaining(
      duration: const Duration(hours: 2, minutes: 30),
      text: (d) => 'Expires in $d',
    );
