import 'dart:math' show pi;

import 'package:intl/intl.dart';

/// A small double value, used to ensure that comparisons between double are
/// valid.
const defaultEpsilon = 1 / 1000;

// Method to convert degrees to radians
double degToRad(num deg) => deg * (pi / 180.0);

String formatDateTime(DateTime dateTime) {
  var format = DateFormat("yyyy-MMM-dd HH:mm:ss");
  return format.format(dateTime);
}

