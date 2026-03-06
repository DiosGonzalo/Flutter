import 'package:aplicacion_movil_punctual/core/app_colors.dart';
import 'package:aplicacion_movil_punctual/core/model/schedule_day.dart';
import 'package:aplicacion_movil_punctual/core/model/schedule_screen_data.dart';
import 'package:aplicacion_movil_punctual/core/service/employee_api_service.dart';
import 'package:flutter/material.dart';

class HomeScheduleScreen extends StatefulWidget {
  const HomeScheduleScreen({super.key});

  @override
  State<HomeScheduleScreen> createState() => _HomeScheduleScreenState();
}

class _HomeScheduleScreenState extends State<HomeScheduleScreen> {
  final EmployeeApiService _employeeApiService = EmployeeApiService();
  late Future<ScheduleScreenData> _scheduleFuture;

  @override
  void initState() {
    super.initState();
    _scheduleFuture = _employeeApiService.fetchScheduleScreen();
  }

  Future<void> _reload() async {
    setState(() {
      _scheduleFuture = _employeeApiService.fetchScheduleScreen();
    });
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
          child: FutureBuilder<ScheduleScreenData>(
            future: _scheduleFuture,
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
                        const Text('No se pudo cargar el horario', style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 8),
                        Text('${snapshot.error}', style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: _reload, child: const Text('Reintentar')),
                      ],
                    ),
                  ),
                );
              }

              final schedule = snapshot.data!;
              final stats = schedule.weeklyStats;

              return RefreshIndicator(
                onRefresh: _reload,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                  children: [
                    const _ScreenHeader(),
                    const SizedBox(height: 12),
                    _StatsCard(
                      totalHours: stats.totalHours,
                      averageHours: stats.averageHours,
                      attendance: stats.attendance,
                      workedDays: stats.workedDays,
                    ),
                    const SizedBox(height: 12),
                    ...schedule.days.asMap().entries.map((entry) => _DayItem(index: entry.key, day: entry.value)),
                    const SizedBox(height: 4),
                    const _WeekendLabel(),
                    const SizedBox(height: 14),
                    _MonthSummaryCard(summary: schedule.monthlySummary),
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

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const monthNames = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(Icons.chevron_left_rounded, color: Colors.white70, size: 24),
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mi Horario',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
            ),
            Text(
              '${monthNames[now.month - 1]} ${now.year}',
              style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w500, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String totalHours;
  final String averageHours;
  final String attendance;
  final int workedDays;

  const _StatsCard({
    required this.totalHours,
    required this.averageHours,
    required this.attendance,
    required this.workedDays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(colors: [AppColors.blueStart, AppColors.blueEnd]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estadísticas de la Semana', style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _statBlock('Total Horas', totalHours)),
              const SizedBox(width: 8),
              Expanded(child: _statBlock('Promedio Entrada', averageHours)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _statBlock('A Tiempo', '$workedDays días')),
              const SizedBox(width: 8),
              Expanded(child: _statBlock('Asistencia', attendance)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBlock(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white.withOpacity(0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.80), fontSize: 9, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.05)),
        ],
      ),
    );
  }
}

class _DayItem extends StatelessWidget {
  final int index;
  final ScheduleDay day;

  const _DayItem({required this.index, required this.day});

  @override
  Widget build(BuildContext context) {
    final labels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final dayLabel = labels[index % labels.length];

    final Color bgColor;
    final Color borderColor;
    final Color accent;
    final String status;

    if (day.completed) {
      bgColor = const Color(0xFF022D2A);
      borderColor = const Color(0xFF0E7B66);
      accent = const Color(0xFF00E29B);
      status = day.statusLabel;
    } else if (day.late) {
      bgColor = const Color(0xFF2A1D15);
      borderColor = const Color(0xFF8A4B1D);
      accent = const Color(0xFFFFA114);
      status = day.statusLabel;
    } else {
      bgColor = const Color(0xFF1A2B47);
      borderColor = AppColors.border.withOpacity(0.65);
      accent = Colors.white54;
      status = day.statusLabel;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            margin: const EdgeInsets.only(top: 2),
            child: Column(
              children: [
                Text(dayLabel, style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  '${day.day}',
                  style: TextStyle(color: accent, fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.circle_outlined, color: accent, size: 13),
                    const SizedBox(width: 6),
                    Text(status, style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 5),
                Text('Horario: ${day.title}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                const SizedBox(height: 2),
                Text(day.subtitle, style: const TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Horas a trabajar', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w500, fontSize: 9)),
              Text(day.plannedHours, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 19, height: 1.05)),
              const SizedBox(height: 6),
              const Text('Trabajadas', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w500, fontSize: 9)),
              Text(day.workedHours, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 19, height: 1.05)),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekendLabel extends StatelessWidget {
  const _WeekendLabel();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Fin de semana',
        style: TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _MonthSummaryCard extends StatelessWidget {
  final MonthlyScheduleSummary summary;

  const _MonthSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF081126),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumen del Mes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 12),
          _summaryLine('Días laborados', '${summary.workedDays} / ${summary.totalDays}'),
          const SizedBox(height: 10),
          _summaryLine('Total horas', summary.totalHours),
          const SizedBox(height: 10),
          _summaryLine('Puntualidad', '${summary.punctualityPct}%'),
        ],
      ),
    );
  }

  Widget _summaryLine(String label, String value) {
    return Row(
      children: [
        const Icon(Icons.circle_outlined, color: Color(0xFF00D08A), size: 13),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12))),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20, height: 1)),
      ],
    );
  }
}
