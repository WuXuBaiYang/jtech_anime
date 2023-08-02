class FFMpegProgress {
  FFMpegProgressPhase phase;
  int fileSize;
  int downloaded;

  FFMpegProgress({
    required this.phase,
    required this.fileSize,
    required this.downloaded,
  });
}

enum FFMpegProgressPhase {
  downloading,
  decompressing,
  inactive,
}
