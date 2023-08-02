const _microsPerHour = 3.6e9;
const _microsPerMinute = 6e7;
const _microsPerSecond = 1000000;
const _microsPerMillisecond = 1000;

Duration parseFfmpegTimeDuration(String durationString) {
  if (durationString.endsWith('ms')) {
    return parseUnitSpecificDuration(durationString);
  } else if (durationString.endsWith('us')) {
    return parseUnitSpecificDuration(durationString);
  } else if (durationString.endsWith('s')) {
    return parseUnitSpecificDuration(durationString);
  } else {
    return parseStandardDuration(durationString);
  }
}

Duration parseStandardDuration(String durationString) {
  if (durationString.isEmpty) {
    throw Exception('Duration string must be non-empty: $durationString');
  }

// Process and remove a negative sign, if it exists.
  bool isNegative = durationString[0] == '-';
  if (isNegative) {
    durationString = durationString.substring(1);
  }

  final timeComponents = durationString.split(':');
  final secondsWithFraction = timeComponents.removeLast();
  final seconds = double.parse(secondsWithFraction).truncate();
  final microseconds = ((double.parse(secondsWithFraction) - seconds) * _microsPerSecond)
      .truncate(); // truncate shouldn't change anything. we just need an int.
  String minutes = '';
  String hours = '';
  if (timeComponents.isNotEmpty) {
    minutes = timeComponents.removeLast();
  }
  if (timeComponents.isNotEmpty) {
    hours = timeComponents.removeLast();
  }
  if (timeComponents.isNotEmpty) {
    throw Exception('A standard format duration cannot have any time components beyond hours: "$durationString"');
  }

  final signMultiplier = isNegative ? -1 : 1;
  return Duration(
    hours: (hours.isEmpty ? 0 : int.parse(hours)) * signMultiplier,
    minutes: (minutes.isEmpty ? 0 : int.parse(minutes)) * signMultiplier,
    seconds: seconds * signMultiplier,
    microseconds: microseconds * signMultiplier,
  );
}

Duration parseUnitSpecificDuration(String unitSpecificDuration) {
  String durationString = unitSpecificDuration;
  if (durationString.isEmpty) {
    throw Exception('Duration string must be non-empty: $unitSpecificDuration');
  }

  bool isNegative = durationString[0] == '-';
  if (isNegative) {
    durationString = durationString.substring(1);
  }

  int wholeValue;
  int wholeValueMicroMultiplier;
  int fractionalValue;
  int fractionValueMicroMultiplier;

  if (durationString.endsWith('ms')) {
    durationString = durationString.substring(0, durationString.length - 2);
    wholeValueMicroMultiplier = _microsPerMillisecond;
    fractionValueMicroMultiplier = 1;
  } else if (durationString.endsWith('us')) {
    durationString = durationString.substring(0, durationString.length - 2);
    wholeValueMicroMultiplier = 1;
    fractionValueMicroMultiplier = 0; // there should never a microsecond fraction.
  } else if (durationString.endsWith('s')) {
    durationString = durationString.substring(0, durationString.length - 1);
    wholeValueMicroMultiplier = _microsPerSecond;
    fractionValueMicroMultiplier = _microsPerMillisecond;
  } else {
    throw Exception('Unit-specific durations must specify the time unit: "$unitSpecificDuration"');
  }

  final timeComponents = durationString.split('+');
  if (timeComponents.length == 1) {
    wholeValue = int.parse(timeComponents[0]);
    fractionalValue = 0;
  } else if (timeComponents.length == 2) {
    wholeValue = int.parse(timeComponents[0]);
    fractionalValue = int.parse(timeComponents[1].substring(1)); // Remove leading '.' from fraction
  } else {
    throw Exception('Invalid unit-specific duration: "$unitSpecificDuration');
  }

  final signMultiplier = isNegative ? -1 : 1;
  return Duration(
    microseconds:
        ((wholeValue * wholeValueMicroMultiplier) + (fractionalValue * fractionValueMicroMultiplier)) * signMultiplier,
  );
}

extension FfmpegDuration on Duration {
  String toStandardFormat() {
    final hours = inHours.abs();
    final minutes = inMinutes.abs() - (hours * 60);
    final seconds = inSeconds.abs() - (minutes * 60) - (hours * 60 * 60);
    final fraction =
        (inMicroseconds.abs() - (seconds * _microsPerSecond) - (minutes * _microsPerMinute) - (hours * _microsPerHour))
                .toDouble() /
            _microsPerSecond;

    final stringBuffer = StringBuffer();
    final sign = isNegative ? '-' : '';
    stringBuffer.write(sign);
    // Hours
    if (hours > 0) {
      stringBuffer.write('${hours.toString().padLeft(2, '0')}:');
    }
    // Minutes
    if (minutes > 0 || hours > 0) {
      stringBuffer.write('${minutes.toString().padLeft(2, '0')}:');
    }
    // Seconds
    if (hours > 0 || minutes > 0) {
      stringBuffer.write(seconds.toString().padLeft(2, '0'));
    } else {
      stringBuffer.write(seconds.toString());
    }
    // Fraction
    if (fraction > 0) {
      stringBuffer.write(fraction.toString().substring(1)); // cut off the leading '0'
    }
    return stringBuffer.toString();
  }

  String toUnitSpecifiedFormat(FfmpegTimeUnit timeUnit) {
    final sign = isNegative ? '-' : '';
    late int whole;
    double? fraction;
    String? units;
    switch (timeUnit) {
      case FfmpegTimeUnit.seconds:
        whole = inSeconds.abs();
        fraction = (inMicroseconds.abs() - (whole * 1000000)).toDouble() / 1000000;
        units = 's';
        break;
      case FfmpegTimeUnit.milliseconds:
        whole = inMilliseconds.abs();
        fraction = (inMicroseconds.abs() - (whole * 1000)).toDouble() / 1000;
        units = 'ms';
        break;
      case FfmpegTimeUnit.microseconds:
        whole = inMicroseconds.abs();
        fraction = 0;
        units = 'us';
        break;
    }

    final fractionString =
        fraction == 0 ? '' : '+${fraction.toString().substring(1)}'; // Cut the leading '0' off the fraction
    return '$sign$whole$fractionString$units';
  }

  String toSeconds() {
    final seconds = inSeconds;
    final fraction = (inMicroseconds - (seconds * _microsPerSecond)) / _microsPerSecond;
    return '${seconds + fraction}';
  }
}

enum FfmpegTimeUnit {
  seconds,
  milliseconds,
  microseconds,
}

class FfmpegTimeBase {
  // TODO:
}

class FfmpegTimestamp {
  // TODO:
}
