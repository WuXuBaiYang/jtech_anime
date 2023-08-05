import '../../abstract_classes/ffmpeg_filter_abstract.dart';

class CropFilter implements Filter {
  const CropFilter({
    required this.width,
    required this.height,
    this.x = 0,
    this.y = 0,
  });

  final int width;
  final int height;
  final int x;
  final int y;

  @override
  String toCli() {
    return 'crop=$width:$height:$x:$y';
  }
}
