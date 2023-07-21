import 'package:flutter_test/flutter_test.dart';
import 'package:jtech_anime/manage/download.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/model/database/download_record.dart';
import 'package:jtech_anime/tool/file.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // m3u8文件测试
  const downUrl = 'https://s9.fsvod1.com/20230721/m2j2LxNl/index.m3u8';
// mp4文件测试
// const downUrl =
//     'https://s9.fsvod1.com/20230721/m2j2LxNl/index.m3u8';
  final record = DownloadRecord()
    ..title = '下载测试'
    ..cover = '下载测试'
    ..url = 'https://www.yhdmz.org/showp/23143.html'
    ..source = parserHandle.currentSource
    ..resName = '资源1'
    ..downloadUrl = downUrl
    ..name = '第一集';
  test('新增下载/恢复下载', () async {
    // final a = download.startTask(record);
    final a = await FileTool.getDirPath('test');
    print(a);
  });
  test('停止下载', () async {
    download.stopTask(record);
  });
  test('删除下载', () async {
    download.removeTask(record);
  });
}
