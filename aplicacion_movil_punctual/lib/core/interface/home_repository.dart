import 'package:aplicacion_movil_punctual/core/dto/weekly_stats_dto.dart';
import 'package:aplicacion_movil_punctual/core/model/schedule_day.dart';

abstract class HomeRepository {
  WeeklyStatsDto getWeeklyStats();
  List<ScheduleDay> getCurrentWeekSchedule();
}