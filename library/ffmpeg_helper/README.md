<p >
<a href="https://www.buymeacoffee.com/abhayrawat" target="_blank"><img align="center" src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="30px" width= "108px"></a>
</p> 

# ffmpeg_helper
FFmpeg commands helper for flutter with support for setup on windows platform.
Create thumbnail and run ffprobe on all platforms except WEB.
This uses ffmpeg_kit_flutter_min_gpl package for android/ios/macos
Info was taken from ffmpeg_cli and recreated it as that project was stale.
```dart
// Initialize in main
  await FFMpegHelper.instance.initialize(); // This is a singleton instance
  // FFMpegHelper ffmpeg = FFMpegHelpe.instance; // use like this
  runApp(const MyApp());
```
```dart
// Command builder
// Use prebuilt args and filters or create custom ones
final FFMpegCommand cliCommand = FFMpegCommand(
  inputs: [
    FFMpegInput.asset(selectedFile!.path),
  ],
  args: [
    const LogLevelArgument(LogLevel.info),
    const OverwriteArgument(),
    const TrimArgument(
      start: Duration(seconds: 0),
      end: Duration(seconds: 10),
    ),
  ],
  filterGraph: FilterGraph(
    chains: [
      FilterChain(
        inputs: [],
        filters: [
          ScaleFilter(
            height: 300,
            width: -2,
          ),
        ],
        outputs: [],
      ),
    ],
  ),
  outputFilepath: path.join(appDocDir.path, "ffmpegtest.mp4"),
);
FFMpegHelperSession session = await ffmpeg.runAsync(
  cliCommand,
  statisticsCallback: (Statistics statistics) {
    print('bitrate: ${statistics.getBitrate()}');
  },
);
```

# Thumbnail creator
```dart
// use ffmpeg.getThumbnailFileAsync() to get session
Future<FFMpegHelperSession> getThumbnailFileAsync({
  required String videoPath,
  required Duration fromDuration,
  required String outputPath,
  String? ffmpegPath,
  FilterGraph? filterGraph,
  int qualityPercentage = 100,
  Function(Statistics statistics)? statisticsCallback,
  Function(File? outputFile)? onComplete,
  FFMpegConfigurator? ffMpegConfigurator,
})
// use ffmpeg.getThumbnailFileSync() to get thumbnail file
Future<File?> getThumbnailFileSync({
  required String videoPath,
  required Duration fromDuration,
  required String outputPath,
  String? ffmpegPath,
  FilterGraph? filterGraph,
  int qualityPercentage = 100,
  Function(Statistics statistics)? statisticsCallback,
  Function(File? outputFile)? onComplete,
  FFMpegConfigurator? ffMpegConfigurator,
})
```
# Run FFMpeg and get session so that user can cancel it later.
```dart
Future<FFMpegHelperSession> runAsync(
  FFMpegCommand command, {
  Function(Statistics statistics)? statisticsCallback,
  Function(File? outputFile)? onComplete,
  Function(Log)? logCallback,
})
```
# Run FFMpeg as future.
```dart
Future<File?> runSync(
  FFMpegCommand command, {
  Function(Statistics statistics)? statisticsCallback,
})
```
# Run ffprobe
```dart
Future<MediaInformation?> runProbe(String filePath)
```
# Setup FFMPEG for Linux
```
sudo apt-get install ffmpeg
OR
sudo snap install ffmpeg
depends on linux distro
```
# Setup FFMPEG for windows
```dart
Future<void> downloadFFMpeg() async {
    if (Platform.isWindows) {
      bool success = await ffmpeg.setupFFMpegOnWindows(
        onProgress: (FFMpegProgress progress) {
          downloadProgress.value = progress;
        },
      );
      setState(() {
        ffmpegPresent = success;
      });
    } else if (Platform.isLinux) {
      // show dialog box
      await Dialogs.materialDialog(
          color: Colors.white,
          msg:
              'FFmpeg installation required by user.\nsudo apt-get install ffmpeg\nsudo snap install ffmpeg',
          title: 'Install FFMpeg',
          context: context,
          actions: [
            IconsButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: 'Ok',
              iconData: Icons.done,
              color: Colors.blue,
              textStyle: const TextStyle(color: Colors.white),
              iconColor: Colors.white,
            ),
          ]);
    }
  }
```
```dart
// check setup progress on windows
// On windows if ffmpeg is not present it will download official zip file and extract on doc directory of app.
SizedBox(
  width: 300,
  child: ValueListenableBuilder(
    valueListenable: downloadProgress,
    builder: (BuildContext context, FFMpegProgress value, _) {
      //print(value.downloaded / value.fileSize);
      double? prog;
      if ((value.downloaded != 0) && (value.fileSize != 0)) {
        prog = value.downloaded / value.fileSize;
      } else {
        prog = 0;
      }
      if (value.phase == FFMpegProgressPhase.decompressing) {
        prog = null;
      }
      if (value.phase == FFMpegProgressPhase.inactive) {
        return const SizedBox.shrink();
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value.phase.name),
          const SizedBox(height: 5),
          LinearProgressIndicator(value: prog),
        ],
      );
    },
  ),
),
```