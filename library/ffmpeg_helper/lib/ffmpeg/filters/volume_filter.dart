import '../../abstract_classes/ffmpeg_filter_abstract.dart';

/// Adjusts the volume of a given audio stream.
class VolumeFilter implements Filter {
  const VolumeFilter({
    required this.volume,
  });

  final double volume;

  @override
  String toCli() {
    return 'volume=$volume';
  }
}
