/*
 * STUB: FlutterFlow Audio Player
 * Original package assets_audio_player is incompatible with modern Android/Kotlin
 * Use AudioService with just_audio instead for actual audio playback
 */

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart' show routeObserver;

// Stub classes for compatibility
class Audio {
  final String path;
  final Metas metas;
  final String audioType;

  Audio(this.path, {Metas? metas})
      : metas = metas ?? Metas(),
        audioType = 'file';

  Audio.network(this.path, {Metas? metas})
      : metas = metas ?? Metas(),
        audioType = 'network';
}

class Metas {
  final String? id;
  final String? title;
  final String? artist;
  Metas({this.id, this.title, this.artist});
}

enum PlayInBackground { enabled, disabled }

class FlutterFlowAudioPlayer extends StatefulWidget {
  const FlutterFlowAudioPlayer({
    super.key,
    required this.audio,
    required this.titleTextStyle,
    required this.playbackDurationTextStyle,
    required this.fillColor,
    required this.playbackButtonColor,
    required this.activeTrackColor,
    this.inactiveTrackColor,
    required this.elevation,
    this.pauseOnNavigate = true,
    required this.playInBackground,
  });

  final Audio audio;
  final TextStyle titleTextStyle;
  final TextStyle playbackDurationTextStyle;
  final Color fillColor;
  final Color playbackButtonColor;
  final Color activeTrackColor;
  final Color? inactiveTrackColor;
  final double elevation;
  final bool pauseOnNavigate;
  final PlayInBackground playInBackground;

  @override
  _FlutterFlowAudioPlayerState createState() => _FlutterFlowAudioPlayerState();
}

class _FlutterFlowAudioPlayerState extends State<FlutterFlowAudioPlayer>
    with RouteAware {
  bool _subscribedRoute = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (_subscribedRoute) {
      routeObserver.unsubscribe(this);
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(FlutterFlowAudioPlayer old) {
    super.didUpdateWidget(old);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.pauseOnNavigate && ModalRoute.of(context) is PageRoute) {
      _subscribedRoute = true;
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    }
  }

  @override
  void didPushNext() {}

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: widget.elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.fillColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.audio.metas.title ?? 'Audio Player (Disabled)',
                        style: widget.titleTextStyle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Use AudioService for playback',
                        style: widget.playbackDurationTextStyle,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.info_outline,
                  color: widget.playbackButtonColor,
                  size: 34,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String generateRandomAlphaNumericString() {
  const chars = 'abcdefghijklmnopqrstuvwxyz1234567890';
  return String.fromCharCodes(Iterable.generate(
      8, (_) => chars.codeUnits[math.Random().nextInt(chars.length)]));
}
