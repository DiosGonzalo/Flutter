import 'package:aplicacion_movil_punctual/core/dto/weekly_stats_dto.dart';
import 'package:aplicacion_movil_punctual/core/model/schedule_day.dart';

class MonthlyScheduleSummary {
  final int workedDays;
  final int totalDays;
  final String totalHours;
  final int punctualityPct;

  const MonthlyScheduleSummary({
    required this.workedDays,
    required this.totalDays,
    required this.totalHours,
    required this.punctualityPct,
  });
}

class ScheduleScreenData {
  final WeeklyStatsDto weeklyStats;
  final List<ScheduleDay> days;
  final MonthlyScheduleSummary monthlySummary;

  const ScheduleScreenData({
    required this.weeklyStats,
    required this.days,
    required this.monthlySummary,
  });
}
