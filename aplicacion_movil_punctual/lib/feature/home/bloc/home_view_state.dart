import 'package:aplicacion_movil_punctual/core/dto/weekly_stats_dto.dart';
import 'package:aplicacion_movil_punctual/core/interface/home_repository.dart';
import 'package:aplicacion_movil_punctual/core/model/schedule_day.dart';

class HomeViewState {
  final HomeRepository repository;

  const HomeViewState(this.repository);

  WeeklyStatsDto get stats => repository.getWeeklyStats();
  List<ScheduleDay> get weekDays => repository.getCurrentWeekSchedule();
}