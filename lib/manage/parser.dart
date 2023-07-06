import 'package:jtech_anime/common/manage.dart';
import 'package:jtech_anime/common/parser.dart';

/*
* 解析器管理
* @author wuxubaiyang
* @Time 2022/3/17 14:14
*/
class ParserHandleManage extends BaseManage { // with ParserHandle
  static final ParserHandleManage _instance = ParserHandleManage._internal();

  factory ParserHandleManage() => _instance;

  ParserHandleManage._internal();
}

// 单例调用
final parserHandle = ParserHandleManage();
