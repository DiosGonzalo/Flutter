import 'package:aplicacion_movil_punctual/config/app_routes.dart';
import 'package:aplicacion_movil_punctual/core/app_colors.dart';
import 'package:aplicacion_movil_punctual/core/model/profile_data.dart';
import 'package:aplicacion_movil_punctual/core/service/auth_api_service.dart';
import 'package:aplicacion_movil_punctual/core/service/employee_api_service.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final EmployeeApiService _employeeApiService = EmployeeApiService();
  final AuthApiService _authApiService = AuthApiService();
  late Future<ProfileData> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _employeeApiService.fetchProfile();
  }

  Future<void> _reload() async {
    setState(() {
      _profileFuture = _employeeApiService.fetchProfile();
    });
  }

  Future<void> _logout() async {
    await _authApiService.logout();
    if (!mounted) {
      return;
    }
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgSecondary, AppColors.bgPrimary],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<ProfileData>(
            future: _profileFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('No se pudo cargar el perfil', style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 8),
                        Text('${snapshot.error}', style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: _reload, child: const Text('Reintentar')),
                      ],
                    ),
                  ),
                );
              }

              final profile = snapshot.data!;
              final hasPermissionsData =
                  profile.vacations.total > 0 ||
                  profile.vacations.used > 0 ||
                  profile.personalDays.total > 0 ||
                  profile.personalDays.used > 0 ||
                  profile.medicalLeaves.total > 0 ||
                  profile.medicalLeaves.used > 0;
              final hasAchievementsData = profile.achievements.isNotEmpty;
                final hasInfoData =
                  profile.email.isNotEmpty ||
                  profile.phone.isNotEmpty ||
                  profile.department.isNotEmpty ||
                  profile.workplace.isNotEmpty ||
                  profile.schedule.isNotEmpty;

              return RefreshIndicator(
                onRefresh: _reload,
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    _ProfileHeader(name: profile.fullName, role: profile.role),
                    if (hasInfoData) ...[
                      const SizedBox(height: 10),
                      _InfoCard(profile: profile),
                    ],
                    const SizedBox(height: 10),
                    _MetricCard(profile: profile),
                    if (hasPermissionsData) ...[
                      const SizedBox(height: 10),
                      _PermissionsCard(profile: profile),
                    ],
                    if (hasAchievementsData) ...[
                      const SizedBox(height: 10),
                      _AchievementsCard(profile: profile),
                    ],
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.dashboard),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: AppColors.border)),
                      icon: const Icon(Icons.space_dashboard_outlined),
                      label: const Text('Volver al dashboard'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: AppColors.border)),
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: const Text('Ver mi horario'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF300A1A),
                        foregroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar Sesión'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String role;

  const _ProfileHeader({required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(colors: [AppColors.blueStart, AppColors.blueEnd]),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFF0F1B35),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text(role, style: const TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            ),
          ),
          const Icon(Icons.badge_outlined, color: Colors.white70, size: 18),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final ProfileData profile;

  const _MetricCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        children: [
          _metricTile('Puntualidad', profile.punctuality, Icons.trending_up_rounded),
          const SizedBox(height: 8),
          _metricTile('Cumplimiento mensual', profile.monthlyCompliance, Icons.calendar_month_rounded),
          const SizedBox(height: 8),
          _metricTile('Asistencia anual', profile.annualAttendance, Icons.fact_check_outlined),
        ],
      ),
    );
  }

  Widget _metricTile(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11))),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final ProfileData profile;

  const _InfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informacion del Perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 10),
          if (profile.email.isNotEmpty) _infoRow('Correo', profile.email, Icons.email_outlined),
          if (profile.phone.isNotEmpty) _infoRow('Telefono', profile.phone, Icons.phone_outlined),
          if (profile.department.isNotEmpty) _infoRow('Departamento', profile.department, Icons.apartment_outlined),
          if (profile.workplace.isNotEmpty) _infoRow('Sede', profile.workplace, Icons.place_outlined),
          if (profile.schedule.isNotEmpty) _infoRow('Horario', profile.schedule, Icons.schedule_outlined),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                const SizedBox(height: 1),
                Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionsCard extends StatelessWidget {
  final ProfileData profile;

  const _PermissionsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Balance de Permisos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 10),
          _ProgressLine(label: 'Vacaciones', value: profile.vacations.text, factor: profile.vacations.factor, color: AppColors.blueEnd),
          _ProgressLine(label: 'Días Personales', value: profile.personalDays.text, factor: profile.personalDays.factor, color: const Color(0xFF38BDF8)),
          _ProgressLine(label: 'Permisos Médicos', value: profile.medicalLeaves.text, factor: profile.medicalLeaves.factor, color: AppColors.success),
        ],
      ),
    );
  }
}

class _AchievementsCard extends StatelessWidget {
  final ProfileData profile;

  const _AchievementsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Logros Recientes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 10),
          ...profile.achievements.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_outlined, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                        if (item.subtitle.isNotEmpty)
                          Text(item.subtitle, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                  ),
                  if (item.date.isNotEmpty) Text(item.date, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;

  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF081126),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final String label;
  final String value;
  final double factor;
  final Color color;

  const _ProgressLine({required this.label, required this.value, required this.factor, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11))),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: factor,
              minHeight: 4,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
