import '../../abstract_classes/ffmpeg_filter_abstract.dart';

/// Add horizontal flip filter
class HFlipFilter implements Filter {
  @override
  String toCli() {
    return 'hflip';
  }
}
