class SimpleTime {
  final int hour;
  final int minute;

  const SimpleTime(this.hour, this.minute);

  bool get isValid => hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
