class ScheduleDay {
  final int day;
  final String statusLabel;
  final String title;
  final String subtitle;
  final String plannedHours;
  final String workedHours;
  final bool completed;
  final bool late;

  const ScheduleDay({
    required this.day,
    required this.statusLabel,
    required this.title,
    required this.subtitle,
    required this.plannedHours,
    required this.workedHours,
    required this.completed,
    required this.late,
  });
}