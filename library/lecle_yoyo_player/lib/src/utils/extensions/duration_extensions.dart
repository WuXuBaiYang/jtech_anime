/// Extension methods for [Duration] class object
extension DurationExtensions on Duration {
  /// Method to convert a duration into a String format like "00:00:00".
  /// The hours will be reduced if less than 0.
  String convertDurationToString() {
    var hours = '';
    if (inHours > 0) {
      if (inHours.toString().length == 1) {
        hours = '0$inHours';
      } else {
        hours = inHours.toString();
      }
    }

    var minutes = inMinutes.toString();
    if (minutes.length == 1) {
      minutes = '0$minutes';
    }

    var seconds = (inSeconds % 60).toString();
    if (seconds.length == 1) {
      seconds = '0$seconds';
    }

    return "${hours.isNotEmpty ? "$hours:" : hours}$minutes:$seconds";
  }
}
