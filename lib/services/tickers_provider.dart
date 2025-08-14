import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class TickersProvider extends ChangeNotifier {
  final Ticker ticker;
  final Ticker oppositeTicker;

  TickersProvider(TickerProvider tickerProvider)
      : ticker = tickerProvider.createTicker((elapsed) {
          // Handle ticker callback
        }),
        oppositeTicker = tickerProvider.createTicker((elapsed) {
          // Handle opposite ticker callback
        });

  void startBoth() {
    ticker.start();
    oppositeTicker.start();
  }

  void stopBoth() {
    ticker.stop();
    oppositeTicker.stop();
  }

  void startOpposite() {
    oppositeTicker.start();
  }

  void stopOpposite() {
    oppositeTicker.stop();
  }

  void start() {
    ticker.start();
  }

  void stop() {
    ticker.stop();
  }

  @override
  void dispose() {
    ticker.dispose();
    oppositeTicker.dispose();
    super.dispose();
  }
}
