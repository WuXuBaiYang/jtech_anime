import '../../abstract_classes/ffmpeg_arguments_abstract.dart';

class CRFArgument implements CliArguments {
  /// The range of the quantizer scale is 0-51: where 0 is lossless, 23 is default, and 51 is worst possible.
  ///
  /// A lower value is a higher quality and a subjectively sane range is 18-28.
  ///
  /// Consider 18 to be visually lossless or nearly so: it should look the same or nearly the same as the input but it isn't technically lossless.
  ///
  final int crf;
  const CRFArgument(this.crf);

  @override
  List<String> toArgs() {
    return ['-crf', '$crf'];
  }
}
