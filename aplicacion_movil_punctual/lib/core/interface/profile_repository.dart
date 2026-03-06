import 'package:aplicacion_movil_punctual/core/dto/profile_metrics_dto.dart';
import 'package:aplicacion_movil_punctual/core/model/achievement_item.dart';

abstract class ProfileRepository {
  ProfileMetricsDto getMetrics();
  List<AchievementItem> getRecentAchievements();
}