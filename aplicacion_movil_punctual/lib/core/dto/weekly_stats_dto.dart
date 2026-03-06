class WeeklyStatsDto {
  final String totalHours;
  final String averageHours;
  final String attendance;
  final int workedDays;

  const WeeklyStatsDto({
    required this.totalHours,
    required this.averageHours,
    required this.attendance,
    required this.workedDays,
  });
}