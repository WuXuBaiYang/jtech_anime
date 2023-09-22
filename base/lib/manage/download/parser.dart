import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:jtech_anime_base/tool/log.dart';
import 'package:jtech_anime_base/tool/tool.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/*
* m3u8解析器
* @author wuxubaiyang
* @Time 2023/8/25 8:53
*/
class M3U8Parser {
  // m3u8密钥文件名
  static const keyFilename = 'key.key';

  // m3u8索引文件名
  static const indexFilename = 'index.m3u8';

  // 缓存目录
  static const _cachePath = 'm3u8';

  // 缓存m3u8文件提供本地播放
  Future<File?> cacheFilter(String url, {String? filePath}) async {
    try {
      filePath ??= join(
          (await getTemporaryDirectory()).path, _cachePath, '${md5(url)}.m3u8');
      final indexFile = File(filePath);
      if (indexFile.existsSync()) return indexFile;
      final dir = indexFile.parent;
      if (!dir.existsSync()) dir.createSync(recursive: true);
      final result = await parse(url);
      if (result == null) return null;
      // 替换key与视频分片地址为远程地址
      final keyUrl = result.key;
      var content = result.content;
      if (keyUrl != null) content = content.replaceAll(keyFilename, keyUrl);
      result.resources.forEach((key, value) {
        content = content.replaceAll(key, value);
      });
      final raf = await indexFile.open(mode: FileMode.write);
      await raf.writeString(content);
      await raf.close();
      return indexFile;
    } catch (e) {
      LogTool.e('缓存m3u8文件失败', error: e);
    }
    return null;
  }

  // 下载m3u8文件（如果有key同样下载key）
  Future<M3U8ParserResult?> download(String url, {String? savePath}) async {
    try {
      final dir = Directory(savePath ??=
          join((await getTemporaryDirectory()).path, _cachePath, md5(url)));
      if (!dir.existsSync()) dir.createSync(recursive: true);
      // 如果索引文件存在则不重复解析
      final result = await parse(url);
      if (result == null) return null;
      // 如果存在key则写入key
      final keyUrl = result.key;
      if (keyUrl != null) {
        final keyPath = join(savePath, keyFilename);
        final resp = await Dio().download(keyUrl, keyPath);
        if (resp.statusCode != 200) return null;
      }
      // 写入索引文件
      final indexFile = File(join(savePath, indexFilename));
      final raf = await indexFile.open(mode: FileMode.write);
      await raf.writeString(result.content);
      await raf.close();
      return result..indexFile = indexFile;
    } catch (e) {
      LogTool.e('m3u8文件下载失败', error: e);
    }
    return null;
  }

  // 解析m3u8远程文件并获取全部的下载记录
  Future<M3U8ParserResult?> parse(String url) async {
    try {
      final resp = await Dio().get(url);
      if (resp.statusCode == 200) {
        final content = resp.data;
        final parser = HlsPlaylistParser.create();
        final playlist = await parser.parseString(Uri.parse(url), content);
        if (playlist is HlsMasterPlaylist) {
          final uri = _parseMasterFile(playlist);
          if (uri != null) return parse(uri.toString());
        } else if (playlist is HlsMediaPlaylist) {
          return _parseMediaFile(playlist, content);
        }
      }
    } catch (e) {
      LogTool.e('m3u8文件解析失败', error: e);
    }
    return null;
  }

  // 解析m3u8主文件
  Uri? _parseMasterFile(HlsMasterPlaylist playlist) {
    // 如果多级结构则获取第一条资源再解析
    final urls = playlist.mediaPlaylistUrls;
    if (urls.isEmpty) return null;
    final uri = playlist.mediaPlaylistUrls.first;
    if (uri == null) return null;
    return uri;
  }

  // 解析m3u8媒体文件
  M3U8ParserResult? _parseMediaFile(HlsMediaPlaylist playlist, String content) {
    if (playlist.segments.isEmpty) return null;
    final baseUri = Uri.parse(playlist.baseUri ?? '');
    // 获取密钥下载地址（如果存在）
    String? keyUrl,
        key = playlist.segments.first.fullSegmentEncryptionKeyUri;
    if (key != null) {
      keyUrl = _mergeUrl(key, baseUri);
      content = content.replaceAll(key, keyFilename);
    }
    // 遍历分片列表并同时生成本地索引文件
    var prev = -1;
    final resources = <String, String>{};
    for (final item in playlist.segments) {
      // 拼接分片下载地址
      String? url = item.url;
      if (url == null) continue;
      url = _mergeUrl(url, baseUri);
      final filename = basename(url);
      final temp = _absoluteIndex(filename);
      if (prev != -1 && temp != prev + 1) {
        content = content.replaceAll(filename, '');
        continue;
      }
      prev = temp;
      resources[filename] = url;
      // 替换m3u8文件中得分片地址为本地或远程地址
      content = content.replaceAll(item.url ?? '', filename);
    }
    return M3U8ParserResult(
      key: keyUrl,
      content: content,
      resources: resources,
    );
  }

  // 合并url
  String _mergeUrl(String path, Uri baseUri) {
    if (path.startsWith('http')) return path;
    if (!path.startsWith('/')) {
      final tmp = baseUri.path;
      final index = tmp.lastIndexOf('/');
      path = '${tmp.substring(0, index)}/$path';
    }
    return '${baseUri.scheme}://${baseUri.host}$path';
  }

  // 找到连续文件中不连续的部分
  int _absoluteIndex(String s) {
    s = s.replaceAll('.ts', '');
    final length = s.length;
    if (length != 17 || int.tryParse(s.substring(11, length)) == null) {
      return -1;
    }
    var ret = 0;
    for (int i = s.runes.length - 10; i < s.runes.length; i++) {
      var ascii = s.codeUnitAt(i);
      if (ascii >= 97) {
        ascii -= 87;
      } else {
        ascii -= 48;
      }
      ret = ret * 10 + ascii;
    }
    return ret;
  }
}

/*
* m3u8文件解析结果
* @author wuxubaiyang
* @Time 2023/8/25 11:05
*/
class M3U8ParserResult {
  // 加密key
  final String? key;

  // 索引文件内容
  final String content;

  // 分片资源列表
  final Map<String, String> resources;

  // 索引文件
  File? indexFile;

  M3U8ParserResult({
    required this.key,
    required this.content,
    required this.resources,
  });
}
