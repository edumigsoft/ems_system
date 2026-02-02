import 'package:flutter/material.dart';
import 'package:project_core_shared/project_core_share.dart' show SimpleTime;

extension SimpleTimeExtension on SimpleTime {
  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);
}

extension TimeOfDayExtension on TimeOfDay {
  SimpleTime toSimpleTime() => SimpleTime(hour, minute);
}
