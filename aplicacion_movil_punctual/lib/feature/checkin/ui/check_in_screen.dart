import 'package:aplicacion_movil_punctual/config/app_routes.dart';
import 'package:aplicacion_movil_punctual/core/model/attendance_status_data.dart';
import 'package:aplicacion_movil_punctual/core/service/api_client.dart';
import 'package:aplicacion_movil_punctual/core/service/employee_api_service.dart';
import 'package:flutter/material.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  static const Color _bg1 = Color(0xFF0B1220);
  static const Color _bg2 = Color(0xFF0E1628);
  static const Color _card = Color(0xFF121A2A);
  static const Color _border = Color(0xFF26324A);

  final EmployeeApiService _employeeApiService = EmployeeApiService();
  late Future<AttendanceStatusData> _statusFuture;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _statusFuture = _employeeApiService.fetchAttendanceStatus();
  }

  Future<void> _reload() async {
    setState(() {
      _statusFuture = _employeeApiService.fetchAttendanceStatus();
    });
  }

  Future<void> _registerAttendance(AttendanceStatusData status) async {
    if (_isSending) {
      return;
    }
    setState(() => _isSending = true);

    try {
      if (status.active) {
        await _employeeApiService.checkOut();
      } else {
        await _employeeApiService.checkIn();
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status.active ? 'Salida registrada correctamente' : 'Entrada registrada correctamente'),
        ),
      );

      await _reload();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: Colors.redAccent),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo registrar el fichaje'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg1,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text('Fichaje', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(center: Alignment(0.7, -0.9), radius: 1.2, colors: [_bg2, _bg1]),
          ),
          child: FutureBuilder<AttendanceStatusData>(
            future: _statusFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('No se pudo cargar el estado de asistencia', style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 8),
                      Text('${snapshot.error}', style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _reload, child: const Text('Reintentar')),
                    ],
                  ),
                );
              }

              final status = snapshot.data!;
              final isActive = status.active;

              return RefreshIndicator(
                onRefresh: _reload,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _clockCard(status.now, status.date),
                    const SizedBox(height: 12),
                    _attendanceInfoCard(status),
                    const SizedBox(height: 12),
                    _locationSection(status),
                    const SizedBox(height: 12),
                    _checkButton(isActive, () => _registerAttendance(status)),
                    const SizedBox(height: 12),
                    _daySummary(status),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.dashboard),
                      icon: const Icon(Icons.space_dashboard_outlined),
                      label: const Text('Volver al dashboard'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
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

  Widget _clockCard(String now, String date) {
    return _cardBox(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Text(now, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(date, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _attendanceInfoCard(AttendanceStatusData status) {
    return _cardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment_turned_in_outlined, color: Colors.white),
              SizedBox(width: 8),
              Text('Registro de Asistencia', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          _divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              _pill(
                text: status.active ? 'Sesión activa' : 'Listo para fichar',
                icon: status.active ? Icons.timer_outlined : Icons.login_rounded,
                color: status.active ? const Color(0xFF2563EB) : const Color(0xFF16A34A),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${status.workedHours} trabajados',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _locationSection(AttendanceStatusData status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text('Información de Ubicación', style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600)),
        ),
        _cardBox(
          child: Column(
            children: [
              _locationTile(
                icon: Icons.location_on_outlined,
                title: status.workplace,
                subtitle: 'Ubicación de trabajo',
                trailing: _statusDot(const Color(0xFF64748B)),
              ),
              _divider(),
              _locationTile(
                icon: Icons.wifi,
                title: 'Red WiFi',
                subtitle: status.wifiOk ? 'Verificada' : 'No verificada',
                trailing: Icon(Icons.check_circle, color: status.wifiOk ? const Color(0xFF30D158) : Colors.redAccent),
              ),
              _divider(),
              _locationTile(
                icon: Icons.gps_fixed,
                title: 'GPS',
                subtitle: status.gpsOk ? 'Ubicación confirmada' : 'Sin confirmar',
                trailing: Icon(Icons.check_circle, color: status.gpsOk ? const Color(0xFF30D158) : Colors.redAccent),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _checkButton(bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: _isSending ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: isActive ? const [Color(0xFFEF4444), Color(0xFFB91C1C)] : const [Color(0xFF16A34A), Color(0xFF15803D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? Icons.logout_rounded : Icons.login_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            _isSending
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isActive ? 'Marcar Salida' : 'Marcar Entrada',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        isActive ? 'Cerrar sesión de jornada' : 'Registrar inicio de jornada',
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _daySummary(AttendanceStatusData status) {
    Widget summaryCard(IconData icon, String title, String subtitle) => _cardBox(
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text('Resumen del Día', style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600)),
        ),
        Row(
          children: [
            Expanded(child: summaryCard(Icons.calendar_today_rounded, status.dayShort, 'Hoy')),
            const SizedBox(width: 10),
            Expanded(child: summaryCard(Icons.login_rounded, status.entryToday, 'Entrada')),
            const SizedBox(width: 10),
            Expanded(child: summaryCard(Icons.timer_rounded, status.workedHours, 'Horas')),
          ],
        ),
      ],
    );
  }

  Widget _cardBox({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border.withOpacity(0.6)),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 6))],
      ),
      child: child,
    );
  }

  Widget _divider() => Container(height: 1, color: Colors.white.withOpacity(0.06));

  Widget _pill({required String text, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _locationTile({required IconData icon, required String title, required String subtitle, required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _statusDot(Color color) {
    return Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}
