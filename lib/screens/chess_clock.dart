import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'dart:math';
import '../services/game_provider.dart';
import '../widgets/fixed_width_time.dart';
import '../widgets/animated_blur_overlay.dart';
import '../widgets/chess_controls_widget.dart';

class ChessClockMain extends StatefulWidget {
  const ChessClockMain({super.key});

  @override
  State<ChessClockMain> createState() => _ChessClockMainState();
}

class _ChessClockMainState extends State<ChessClockMain> {
  late GameProvider gameProvider;
  late Duration normalElapsed;
  late Duration invertedElapsed;
  late Duration gameDuration;
  final double bgRadius = 16.0;
  AudioPool? _tapPool; // Ultra-low-latency pool for tap sound
  final AudioPlayer _fallbackPlayer = AudioPlayer();
  String _assetKey = 'assets/audio/chess.m4a';

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
    // Preload the tap sound with a small pool for minimal latency
    _initAudioPool();
  }

  Future<void> _initAudioPool() async {
    // Try common asset keys
    for (final key in <String>['assets/audio/chess.m4a', 'audio/chess.m4a']) {
      try {
        final pool = await AudioPool.create(
          source: AssetSource(key),
          maxPlayers: 2, // handle rapid successive taps
        );
        _tapPool = pool;
        _assetKey = key;
        debugPrint('Tap sound pool initialized with asset: $key');
        break;
      } catch (_) {
        debugPrint('Tap sound pool init failed for: $key');
        // try next key
      }
    }
    if (_tapPool == null) {
      debugPrint('Tap sound pool not ready; fallback player will be used.');
    }
  }

  void _playTap() {
    try {
      if (_tapPool != null) {
        _tapPool!.start();
        return;
      }
      _fallbackPlayer.play(AssetSource(_assetKey));
    } catch (e) {
      debugPrint('Tap sound play error: $e');
      // As a last resort, use a system click sound (very low latency)
      SystemSound.play(SystemSoundType.click);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    gameProvider.normalPlayerTicker.stop();
    gameProvider.invertedPlayerTicker.stop();
    _tapPool?.dispose();
    _fallbackPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    gameProvider = Provider.of<GameProvider>(context, listen: true);
    normalElapsed = gameProvider.normalPlayerElapsed;
    invertedElapsed = gameProvider.invertedPlayerElapsed;
    gameDuration = gameProvider.gameDuration;

    final bool gameIsOver = gameProvider.gameStatus == GameStatus.over;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCirc,
            margin: EdgeInsets.only(
              top: gameProvider.currentPlayerMove == PlayerMove.normal
                  ? MediaQuery.of(context).size.height / 2 +
                      24 +
                      MediaQuery.of(context).padding.top
                  : 0,
              bottom: gameProvider.currentPlayerMove == PlayerMove.inverted
                  ? MediaQuery.of(context).size.height / 2 +
                      24 +
                      MediaQuery.of(context).padding.bottom
                  : 0,
            ),
            decoration: ShapeDecoration(
              color: gameProvider.gameStatus == GameStatus.over
                  ? const Color.fromARGB(255, 255, 21, 0)
                  : Colors.white,
              shape: SmoothRectangleBorder(
                smoothness: 0.6,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    gameProvider.currentPlayerMove == PlayerMove.normal
                        ? bgRadius
                        : 0,
                  ),
                  topRight: Radius.circular(
                    gameProvider.currentPlayerMove == PlayerMove.normal
                        ? bgRadius
                        : 0,
                  ),
                  bottomLeft: Radius.circular(
                    gameProvider.currentPlayerMove == PlayerMove.inverted
                        ? bgRadius
                        : 0,
                  ),
                  bottomRight: Radius.circular(
                    gameProvider.currentPlayerMove == PlayerMove.inverted
                        ? bgRadius
                        : 0,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: IgnorePointer(
                    ignoring:
                        gameProvider.currentPlayerMove == PlayerMove.normal ||
                            gameIsOver,
                    child: GestureDetector(
                      onTapDown: (_) {},
                      onTap: () {
                        _playTap();
                        gameProvider.switchPlayer();
                      },
                      child: Stack(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                            child: SafeArea(
                              child: Center(
                                child: Transform.rotate(
                                  angle: pi,
                                  child: RepaintBoundary(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 32,
                                      ),
                                      child: FixedWidthTime(
                                        elapsed: invertedElapsed,
                                        gameDuration: gameDuration,
                                        isLoser: gameProvider.isPlayerLoser(
                                          PlayerMove.inverted,
                                        ),
                                        gameIsOver: gameIsOver,
                                        increment: gameProvider
                                            .incrementDuration, // Pass increment
                                        style: TextStyle(
                                          fontSize: 48,
                                          color:
                                              gameProvider.currentPlayerMove ==
                                                      PlayerMove.inverted
                                                  ? Colors.grey.shade800
                                                  : Colors.grey.shade500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Positioned(
                          //   bottom: 16,
                          //   left: 0,
                          //   right: 0,
                          //   child: AnimatedOpacity(
                          //     opacity: gameProvider.currentPlayerMove ==
                          //             PlayerMove.normal
                          //         ? 1
                          //         : 0,
                          //     curve: Curves.easeOutCirc,
                          //     duration: const Duration(milliseconds: 500),
                          //     child: Transform.rotate(
                          //       angle: pi,
                          //       child: FixedWidthTime(
                          //         elapsed: normalElapsed,
                          //         gameDuration: gameDuration,
                          //         isLoser: gameProvider.isPlayerLoser(
                          //           PlayerMove.normal,
                          //         ),
                          //         gameIsOver: gameIsOver,
                          //         increment: gameProvider
                          //             .incrementDuration, // Pass increment
                          //         style: TextStyle(
                          //           fontSize: 20,
                          //           color: Colors.grey.shade600,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // Add move counter for inverted player
                          Positioned(
                            top: 0,
                            right: 24,
                            child: Transform.rotate(
                              angle: pi,
                              child: Text(
                                '${gameProvider.invertedPlayerMoves}',
                                style: TextStyle(
                                  color: gameProvider.isPlayerLoser(
                                    PlayerMove.inverted,
                                  )
                                      ? Colors.white // Use white for loser
                                      : gameProvider.currentPlayerMove ==
                                              PlayerMove.inverted
                                          ? Colors.black.withAlpha(100)
                                          : Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                //options and controls
                const ChessControlsWidget(),
                Expanded(
                  child: IgnorePointer(
                    ignoring:
                        gameProvider.currentPlayerMove == PlayerMove.inverted ||
                            gameIsOver,
                    child: GestureDetector(
                      onTap: () {
                        _playTap();
                        gameProvider.switchPlayer();
                      },
                      child: Stack(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(top: 16),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Center(
                              child: RepaintBoundary(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 32,
                                  ),
                                  child: FixedWidthTime(
                                    elapsed: normalElapsed,
                                    gameDuration: gameDuration,
                                    isLoser: gameProvider.isPlayerLoser(
                                      PlayerMove.normal,
                                    ),
                                    gameIsOver: gameIsOver,
                                    increment: gameProvider
                                        .incrementDuration, // Pass increment
                                    style: TextStyle(
                                      fontSize: 48,
                                      color: gameProvider.currentPlayerMove ==
                                              PlayerMove.normal
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Positioned(
                          //   left: 0,
                          //   right: 0,
                          //   top: 16,
                          //   child: AnimatedOpacity(
                          //     opacity: gameProvider.currentPlayerMove ==
                          //             PlayerMove.inverted
                          //         ? 1
                          //         : 0,
                          //     duration: const Duration(milliseconds: 500),
                          //     curve: Curves.easeOutCirc,
                          //     child: FixedWidthTime(
                          //       elapsed: invertedElapsed,
                          //       gameDuration: gameDuration,
                          //       isLoser: gameProvider.isPlayerLoser(
                          //         PlayerMove.inverted,
                          //       ),
                          //       gameIsOver: gameIsOver,
                          //       increment: gameProvider
                          //           .incrementDuration, // Pass increment
                          //       style: TextStyle(
                          //         fontSize: 20,
                          //         color: Colors.grey.shade600,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // Add move counter for normal player
                          Positioned(
                            bottom: 16,
                            left: 24,
                            child: Text(
                              '${gameProvider.normalPlayerMoves}',
                              style: TextStyle(
                                color: gameProvider.isPlayerLoser(
                                  PlayerMove.normal,
                                )
                                    ? Colors.white // Use white for loser
                                    : gameProvider.currentPlayerMove ==
                                            PlayerMove.normal
                                        ? Colors.black.withAlpha(100)
                                        : Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Overlay for paused state
          Selector<GameProvider, bool>(
            selector: (_, gp) => gp.gameStatus == GameStatus.paused,
            builder: (context, isPaused, _) {
              return AnimatedBlurOverlay(
                isVisible: isPaused,
                onTap: () => context.read<GameProvider>().resumeChessClock(),
                blurSigma: 5,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCirc,
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.flip(
                        flipY: true,
                        flipX: true,
                        child: Shimmer.fromColors(
                          baseColor: Colors.white.withAlpha(150),
                          highlightColor: Colors.white.withAlpha(250),
                          child: const Text(
                            'Tap anywhere to resume',
                            style: TextStyle(
                              color: Color.fromARGB(200, 255, 255, 255),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 4 + 40,
                        width: double.maxFinite,
                      ),
                      const Icon(
                        CupertinoIcons.play_fill,
                        size: 50,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Timer Paused',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 4 + 40,
                        width: double.maxFinite,
                      ),
                      Shimmer.fromColors(
                        baseColor: Colors.white.withAlpha(150),
                        highlightColor: Colors.white.withAlpha(250),
                        child: const Text(
                          'Tap anywhere to resume',
                          style: TextStyle(
                            color: Color.fromARGB(200, 255, 255, 255),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
