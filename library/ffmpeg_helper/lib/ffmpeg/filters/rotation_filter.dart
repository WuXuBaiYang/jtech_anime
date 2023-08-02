import '../../abstract_classes/ffmpeg_filter_abstract.dart';

/// Add rotataion to the filter.
class RotationFilter implements Filter {
  final int degrees;

  const RotationFilter({
    required this.degrees,
  });

  @override
  String toCli() {
    return 'rotate=$degrees';
  }
}
