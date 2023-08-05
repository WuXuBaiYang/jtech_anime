import 'ffmpeg_filter_chain.dart';

/// A filter graph that describes how FFMPEG should compose various assets
/// to form a final, rendered video.
///
/// FFMPEG filter graph syntax reference:
/// http://ffmpeg.org/ffmpeg-filters.html#Filtergraph-syntax-1
class FilterGraph {
  const FilterGraph({
    required this.chains,
  });

  final List<FilterChain> chains;

  /// Returns this filter graph in a form that can be run in a CLI command.
  String toCli({indent = ''}) {
    return chains.map((chain) => indent + chain.toCli()).join('; \n');
  }
}
