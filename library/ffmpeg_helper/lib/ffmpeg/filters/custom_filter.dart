import '../../abstract_classes/ffmpeg_filter_abstract.dart';

class RawFilter implements Filter {
  RawFilter(this.cliValue);

  final String cliValue;

  @override
  String toCli() => cliValue;
}
