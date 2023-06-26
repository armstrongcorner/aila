import 'package:intl/intl.dart';

class DateUtil {
  DateUtil._();

  static int getCurrentTimestamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  static String getDetailedTimeStr(DateTime dateTime, String separator) {
    return DateFormat(
            'yyyy${separator}MM${separator}dd${separator}HH${separator}mm${separator}ss')
        .format(dateTime);
  }

  static String getPhotoTimeStr(DateTime dateTime) {
    return DateFormat('yyyy/MM/dd HH:mm').format(dateTime);
  }

  static String getDateOnly(String origTimestamp, {String separator = '-'}) {
    try {
      DateTime theDateTime = DateTime.parse(origTimestamp);
      return DateFormat('yyyy${separator}MM${separator}dd').format(theDateTime);
    } catch (e) {
      print(e);
      return '';
    }
  }

  static bool isContainInDateRange(
      DateTime targetDateTime, DateTime startDateTime, DateTime endDateTime) {
    return targetDateTime.millisecondsSinceEpoch >=
            startDateTime.millisecondsSinceEpoch &&
        targetDateTime.millisecondsSinceEpoch <=
            endDateTime.millisecondsSinceEpoch;
  }

  static int comppareDateTime(int startTimestamp, int endTimestamp,
      {bool isSec = false, bool isMin = true, bool isHr = false}) {
    final startDate = DateTime.fromMillisecondsSinceEpoch(startTimestamp);
    final endDate = DateTime.fromMillisecondsSinceEpoch(endTimestamp);
    final dateDiff = endDate.difference(startDate);

    int diffQty = 0;
    if (isSec) {
      diffQty = dateDiff.inSeconds;
    } else if (isMin) {
      diffQty = dateDiff.inMinutes;
    } else if (isHr) {
      diffQty = dateDiff.inHours;
    }

    return diffQty;
  }
}
