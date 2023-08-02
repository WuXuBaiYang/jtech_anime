import '../../abstract_classes/ffmpeg_arguments_abstract.dart';

class CustomArgument implements CliArguments {
  final List<String> args;
  const CustomArgument(this.args);

  @override
  List<String> toArgs() {
    return args;
  }
}
