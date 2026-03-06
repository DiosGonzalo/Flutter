class AttendanceStatusData {
  final String now;
  final String date;
  final bool active;
  final String activeSince;
  final String workedHours;
  final String entryToday;
  final String exitToday;
  final String workplace;
  final bool wifiOk;
  final bool gpsOk;
  final String dayShort;

  const AttendanceStatusData({
    required this.now,
    required this.date,
    required this.active,
    required this.activeSince,
    required this.workedHours,
    required this.entryToday,
    required this.exitToday,
    required this.workplace,
    required this.wifiOk,
    required this.gpsOk,
    required this.dayShort,
  });
}
