import '../../abstract_classes/ffmpeg_arguments_abstract.dart';

/// Audio bitrate in kbps , eg: 1000kbps
class AddThumbnailArgument implements CliArguments {
  final int thumbInputIndex;
  final int videoInputIndex;
  const AddThumbnailArgument({
    required this.thumbInputIndex,
    required this.videoInputIndex,
  });

  @override
  List<String> toArgs() {
    return [
      '-map',
      '$videoInputIndex',
      '-map',
      '$thumbInputIndex',
      '-disposition:',
      '$videoInputIndex',
    ];
  }
}
