import 'dart:io';

// import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Utility class to implement video caching method
class FileUtils {
  /// Cache file to local storage method using [File] class method.
  static void cacheFileToLocalStorage(
    String videoUrl, {
    Map<String, String>? headers,
    String? fileExtension,
    void Function(File? file)? onSaveCompleted,
    void Function(dynamic err)? onSaveFailed,
  }) {
    http.Client client = http.Client();
    client.get(Uri.parse(videoUrl), headers: headers).then((response) {
      if (response.statusCode == 200) {
        var fileName = _getFileNameFromUrl(videoUrl);

        _writeFile(
          response: response,
          fileExtension: fileExtension,
          onSaveCompleted: onSaveCompleted,
          onSaveFailed: onSaveFailed,
          fileName: fileName,
        );
      }
    }).catchError((err) {
      onSaveFailed?.call(err);
    });
  }

  /// Method to write the downloaded video into device local storage using [writeAsBytes] method
  /// from [File]'s object.
  static void _writeFile({
    required http.Response response,
    String? fileExtension,
    void Function(File file)? onSaveCompleted,
    void Function(dynamic err)? onSaveFailed,
    String? fileName,
  }) async {
    Directory? dir;
    if (Platform.isAndroid) {
      dir = await getExternalStorageDirectory();
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    if (dir != null) {
      File file = File(
        '${dir.path}/${(fileName != null && fileName.isNotEmpty) ? fileName : DateTime.now().millisecondsSinceEpoch}.${fileExtension ?? 'm3u8'}',
      );
      await file.writeAsBytes(response.bodyBytes).then((f) async {
        print('Write file success');
        onSaveCompleted?.call(f);
      }).catchError((err) {
        onSaveFailed?.call(err);
      });
    }
  }

  /// Method to cached video file into device local storage using [FlutterDownloader] plugin.
  // static void cacheFileWithFlutterDownloader({
  //   required String url,
  //   Map<String, String> headers = const {},
  //   void Function(String? taskId)? onSaveCompleted,
  //   void Function(dynamic err)? onSaveFailed,
  // }) async {
  //   Directory? directory;
  //   if (Platform.isAndroid) {
  //     directory = await getExternalStorageDirectory();
  //   } else {
  //     directory = await getApplicationDocumentsDirectory();
  //   }
  //
  //   if (directory != null) {
  //     FlutterDownloader.enqueue(
  //       url: url,
  //       savedDir: directory.path,
  //       // show download progress in status bar (for Android)
  //       showNotification: true,
  //       // click on notification to open downloaded file (for Android)
  //       openFileFromNotification: true,
  //       headers: headers,
  //       saveInPublicStorage: true,
  //     ).then((taskId) {
  //       onSaveCompleted?.call(taskId);
  //     }).catchError((err) {
  //       onSaveFailed?.call(err);
  //     });
  //   }
  // }

  /// Method to get the file name from a video url
  static String _getFileNameFromUrl(String? videoUrl) {
    if (videoUrl != null) {
      return p.basenameWithoutExtension(videoUrl);
    }

    return '';
  }

  /// Method to write the downloaded video into device local storage using [writeAsString] method
  /// from [File]'s object.
  static Future<File> cacheFileUsingWriteAsString({
    required String contents,
    required String quality,
    required String videoUrl,
  }) async {
    final name = _getFileNameFromUrl(videoUrl);
    // var directory = await getApplicationDocumentsDirectory();
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final File file = File(
        '${directory?.path ?? ''}/yoyo_${name.isNotEmpty ? '${name}_' : name}$quality.m3u8');
    return await file.writeAsString(contents).then((f) {
      return f;
    }).catchError((err) {
      print('Write file error $err');
    });
  }

  /// Method to read a cached video file of m3u8 type.
  static Future<File?> readFileFromPath({
    required String videoUrl,
    required String quality,
  }) async {
    final name = _getFileNameFromUrl(videoUrl);
    // var directory = await getApplicationDocumentsDirectory();
    Directory? directory;

    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final File file = File(
      '${directory?.path ?? ''}/yoyo_${name.isNotEmpty ? '${name}_' : name}$quality.m3u8',
    );

    var exists = await file.exists();
    if (exists) return file;

    return null;
  }
}
