import '../abstract_classes/ffmpeg_filter_abstract.dart';
import 'ffmpeg_stream.dart';

/// A single pipeline of operations within a larger filter graph.
///
/// A filter chain has some number of input streams, those streams then
/// have some number of filters applied to them in the given order, and
/// those filters then produce some number of output streams.
class FilterChain {
  const FilterChain({
    required this.inputs,
    required this.filters,
    required this.outputs,
  });

  /// Streams that flow into the [filters].
  final List<FFMpegStream> inputs;

  /// Filters that apply to the [inputs], and generate the [outputs].
  final List<Filter> filters;

  /// New streams that flow out of the [filters], after applying those
  /// [filters] to the [inputs].
  final List<FFMpegStream> outputs;

  /// Formats this filter chain for the FFMPEG CLI.
  ///
  /// Format:
  /// [in1] [in2] [in3] filter1, filter2, [out1] [out2] [out3]
  ///
  /// Example:
  /// [0:0] trim=start='10':end='15' [out_v]
  String toCli() =>
      '${inputs.map((stream) => stream.toString()).join(' ')} ${filters.map((filter) => filter.toCli()).join(', ')} ${outputs.join(' ')}';
}
