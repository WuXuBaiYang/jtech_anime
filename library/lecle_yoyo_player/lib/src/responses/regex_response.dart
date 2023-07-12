/// Regexes use to check the video's content
class RegexResponse {
  /// regexMAIN
  static const String regexMAIN =
      r"^#EXT-X-STREAM-INF:(?:.*,RESOLUTION=(\d+x\d+))?:.*,\r?\n(.*)";

  /// regexMEDIA
  static const String regexMEDIA =
      r"""^#EXT-X-MEDIA:TYPE=AUDIO(?:.*,URI="(.*m3u8)")""";

  /// regexAUDIO
  static const String regexAUDIO = "";

  /// regexSUBTITLE
  static const String regexSUBTITLE = "";

  /// regexSRT
  static const String regexSRT =
      r"^((\d{2}):(\d{2}):(\d{2}),(\d{3})) +--> +((\d{2}):(\d{2}):(\d{2}),(\d{2})).*[\r\n]+\s*((?:(?!\r?\n\r?).)*)";

  /// regexASS
  static const String regexASS = "";

  /// regexVTT
  static const String regexVTT = "";

  /// regexSTREAM
  static const String regexSTREAM = "";

  /// regexFILE
  static const String regexFILE = "";

  /// regexHTTP
  static const String regexHTTP = r'^(http|https):\/\/([\w.]+\/?)\S*';

  /// regexURL
  static const String regexURL = r'(.*)\r?\/';

  /// regexM3U8Resolution
  static const String regexM3U8Resolution =
      r"#EXT-X-STREAM-INF:(?:.*,RESOLUTION=(\d+x\d+))?,?(.*)\r?\n(.*)";
}
