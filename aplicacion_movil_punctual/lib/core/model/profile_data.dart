import 'package:aplicacion_movil_punctual/core/model/achievement_item.dart';

class PermissionBalance {
  final int used;
  final int total;

  const PermissionBalance({required this.used, required this.total});

  double get factor {
    if (total <= 0) {
      return 0;
    }
    return (used / total).clamp(0, 1);
  }

  String get text => '$used / $total';
}

class ProfileData {
  final String fullName;
  final String role;
  final String email;
  final String phone;
  final String department;
  final String workplace;
  final String schedule;
  final String punctuality;
  final String monthlyCompliance;
  final String annualAttendance;
  final PermissionBalance vacations;
  final PermissionBalance personalDays;
  final PermissionBalance medicalLeaves;
  final List<AchievementItem> achievements;

  const ProfileData({
    required this.fullName,
    required this.role,
    required this.email,
    required this.phone,
    required this.department,
    required this.workplace,
    required this.schedule,
    required this.punctuality,
    required this.monthlyCompliance,
    required this.annualAttendance,
    required this.vacations,
    required this.personalDays,
    required this.medicalLeaves,
    required this.achievements,
  });
}
