import 'package:aplicacion_movil_punctual/core/dto/profile_metrics_dto.dart';
import 'package:aplicacion_movil_punctual/core/interface/profile_repository.dart';
import 'package:aplicacion_movil_punctual/core/model/achievement_item.dart';

class ProfileViewState {
  final ProfileRepository repository;

  const ProfileViewState(this.repository);

  ProfileMetricsDto get metrics => repository.getMetrics();
  List<AchievementItem> get achievements => repository.getRecentAchievements();
}