import 'package:aplicacion_movil_punctual/config/app_routes.dart';
import 'package:aplicacion_movil_punctual/core/model/dashboard_data.dart';
import 'package:aplicacion_movil_punctual/core/service/auth_api_service.dart';
import 'package:aplicacion_movil_punctual/core/service/employee_api_service.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color _bgDark1 = Color(0xFF080B13);
  static const Color _bgDark2 = Color(0xFF0E1220);

  final EmployeeApiService _employeeApiService = EmployeeApiService();
  final AuthApiService _authApiService = AuthApiService();
  late Future<DashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _employeeApiService.fetchDashboard();
  }

  Future<void> _reload() async {
    setState(() {
      _dashboardFuture = _employeeApiService.fetchDashboard();
    });
  }

  Future<void> _logout() async {
    await _authApiService.logout();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark1,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.5),
              radius: 1.2,
              colors: <Color>[_bgDark2, _bgDark1],
            ),
          ),
          child: FutureBuilder<DashboardData>(
            future: _dashboardFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'No se pudo cargar el dashboard',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _reload,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final data = snapshot.data!;

              return RefreshIndicator(
                onRefresh: _reload,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    const SizedBox(height: 4),
                    _TopBar(onLogout: _logout),
                    const SizedBox(height: 12),
                    _GreetingHeader(name: data.employeeName, progressPercent: data.progressPercent),
                    const SizedBox(height: 16),
                    _StatsRow(hoursToday: data.hoursTodayText, hoursWeek: data.hoursWeek),
                    const SizedBox(height: 16),
                    const _SectionTitle('Acciones'),
                    const SizedBox(height: 10),
                    _ActionsGrid(entryLabel: data.actionEntryLabel),
                    const SizedBox(height: 18),
                    const _SectionTitle('Resumen de Hoy'),
                    const SizedBox(height: 10),
                    ...data.summaryItems.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _SummaryItem(
                            title: item.title,
                            subtitle: item.detail,
                            status: item.status,
                          ),
                        )),
                    const SizedBox(height: 6),
                    Center(
                      child: TextButton(
                        onPressed: _logout,
                        style: TextButton.styleFrom(foregroundColor: Colors.white70),
                        child: const Text('Cerrar Sesión'),
                      ),
                    ),
                    const SizedBox(height: 24),
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

class _TopBar extends StatelessWidget {
  final VoidCallback onLogout;

  const _TopBar({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.white,
          child: Icon(Icons.schedule_rounded, color: Colors.black87),
        ),
        const SizedBox(width: 8),
        const Text(
          'PUNCTUAL',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        IconButton(
          onPressed: onLogout,
          icon: const Icon(Icons.logout, color: Colors.white70),
        ),
      ],
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  final String name;
  final double progressPercent;

  const _GreetingHeader({required this.name, required this.progressPercent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hola,', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: (progressPercent / 100).clamp(0, 1),
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${progressPercent.toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final String hoursToday;
  final double hoursWeek;

  const _StatsRow({required this.hoursToday, required this.hoursWeek});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(icon: Icons.access_time_rounded, title: 'Horas Hoy', value: hoursToday),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(icon: Icons.show_chart_rounded, title: 'Esta Semana', value: '${hoursWeek.toStringAsFixed(2)}h'),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.9)),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.7))),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w600),
    );
  }
}

class _ActionsGrid extends StatelessWidget {
  final String entryLabel;

  const _ActionsGrid({required this.entryLabel});

  @override
  Widget build(BuildContext context) {
    final isCheckOut = entryLabel.toLowerCase().contains('salida');
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                color: const Color(0xFF16A34A),
                icon: isCheckOut ? Icons.logout_rounded : Icons.login_rounded,
                title: entryLabel,
                subtitle: 'Registrar entrada/salida',
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.checkin),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                color: const Color(0xFF2563EB),
                icon: Icons.calendar_month_rounded,
                title: 'Mi Horario',
                subtitle: 'Ver calendario semanal',
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.home),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ActionCard(
          color: const Color(0xFF7C3AED),
          icon: Icons.person_outline_rounded,
          title: 'Perfil',
          subtitle: 'Estadísticas y configuración',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.8), size: 16),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;

  const _SummaryItem({required this.title, required this.subtitle, required this.status});

  @override
  Widget build(BuildContext context) {
    final Color tagColor = status == 'late'
        ? const Color(0xFFF59E0B)
        : status == 'active'
            ? const Color(0xFF2563EB)
            : const Color(0xFF16A34A);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.white.withOpacity(0.95)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: tagColor.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Text(
              status,
              style: TextStyle(color: tagColor, fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
