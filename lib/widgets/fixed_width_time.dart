import 'package:flutter/material.dart';

class FixedWidthTime extends StatefulWidget {
  final Duration elapsed;
  final Duration gameDuration;
  final TextStyle style;
  final bool isLoser;
  final bool gameIsOver; // New parameter to control blinking animation
  final Duration increment; // Add increment parameter

  const FixedWidthTime({
    super.key,
    required this.elapsed,
    required this.gameDuration,
    required this.style,
    this.isLoser = false,
    this.gameIsOver = false, // Default to false
    this.increment = Duration.zero, // Default to zero increment
  });

  @override
  State<FixedWidthTime> createState() => _FixedWidthTimeState();
}

class _FixedWidthTimeState extends State<FixedWidthTime>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(FixedWidthTime oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Start or stop blinking animation when game status or loser status changes
    if (widget.gameIsOver &&
        widget.isLoser &&
        (!oldWidget.gameIsOver || !oldWidget.isLoser)) {
    } else if (!widget.gameIsOver || !widget.isLoser) {}
  }


  @override
  Widget build(BuildContext context) {
    final Duration actualDuration = widget.gameDuration - widget.elapsed;
    // Ensure we don't display negative times
    final Duration displayDuration =
        actualDuration.isNegative ? Duration.zero : actualDuration;

    final minutes =
        displayDuration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        displayDuration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final milliseconds = displayDuration.inMilliseconds
        .remainder(1000)
        .toString()
        .padLeft(3, '0')
        .substring(0, 2);

    // Use white text color if this player is the loser
    final textStyle = widget.isLoser
        ? widget.style.copyWith(color: Colors.white)
        : widget.style;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        displayDuration.inHours > 0
            ? SizedBox(
                width: widget.style.fontSize! * 1.57,
                child: Text(
                  displayDuration.inHours.toString().padLeft(2, '0'),
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
              )
            : const SizedBox.shrink(),
        displayDuration.inHours > 0
            ? Text(
                ':',
                style: textStyle,
                textAlign: TextAlign.center,
              )
            : const SizedBox.shrink(),
        SizedBox(
          width: widget.style.fontSize! * 1.57,
          child: Text(
            minutes,
            style: textStyle,
            textAlign: TextAlign.center,
          ),
        ),
        Text(
          ':',
          style: textStyle,
          textAlign: TextAlign.center,
        ),
        SizedBox(
          width: widget.style.fontSize! * 1.57,
          child: Text(
            seconds,
            style: textStyle,
            textAlign: TextAlign.center,
          ),
        ),
        // displayDuration.inMinutes == 0
        //     ? Text(
        //         '.',
        //         style: textStyle,
        //         textAlign: TextAlign.center,
        //       )
        //     : SizedBox(),
        // displayDuration.inMinutes == 0
        //     ? SizedBox(
        //         width: widget.style.fontSize! * 1.57,
        //         child: Text(
        //           '$milliseconds',
        //           style: textStyle,
        //           textAlign: TextAlign.center,
        //         ),
        //       )
        //     : SizedBox(),
      ],
    );
  }
}
