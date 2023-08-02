import 'dart:io';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_session.dart';

class FFMpegHelperSession {
  final Function cancelSession;
  final FFmpegSession? nonWindowSession;
  final Process? windowSession;

  FFMpegHelperSession({
    required this.cancelSession,
    this.nonWindowSession,
    this.windowSession,
  });
}
