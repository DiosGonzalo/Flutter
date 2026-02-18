import 'package:flutter/material.dart';

/// Pantalla para fichar entrada.
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

  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    // Actualizar reloj cada segundo
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _now = DateTime.now());
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg1,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text('Fichar Entrada', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.7, -0.9),
              radius: 1.2,
              colors: [_bg2, _bg1],
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _clockCard(),
              const SizedBox(height: 12),
              _attendanceInfoCard(),
              const SizedBox(height: 12),
              _locationSection(),
              const SizedBox(height: 12),
              _checkInButton(context),
              const SizedBox(height: 12),
              _daySummary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _clockCard() {
    final time = _two(_now.hour) + ':' + _two(_now.minute) + ':' + _two(_now.second);
    final dateText = _dateInSpanish(_now);
    return _cardBox(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Text(
            time,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(dateText, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _attendanceInfoCard() {
    return _cardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.assignment_turned_in_outlined, color: Colors.white),
              SizedBox(width: 8),
              Text('Registro de Asistencia',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          _divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              _pill(text: 'Listo para fichar', icon: Icons.login_rounded, color: const Color(0xFF16A34A)),
              const SizedBox(width: 8),
              Text('Su jornada empieza al fichar entrada',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _locationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text('Información de Ubicación',
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600)),
        ),
        _cardBox(
          child: Column(
            children: [
              _locationTile(
                icon: Icons.location_on_outlined,
                title: 'Oficina Central',
                subtitle: 'Av. Principal 123, Ciudad',
                trailing: _statusDot(const Color(0xFF64748B)),
              ),
              _divider(),
              _locationTile(
                icon: Icons.wifi,
                title: 'Red WiFi',
                subtitle: 'EMPRESA-OFFICE',
                trailing: const Icon(Icons.check_circle, color: Color(0xFF30D158)),
              ),
              _divider(),
              _locationTile(
                icon: Icons.gps_fixed,
                title: 'GPS Verificado',
                subtitle: 'Ubicación confirmada',
                trailing: const Icon(Icons.check_circle, color: Color(0xFF30D158)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _checkInButton(BuildContext context) {
    return InkWell(
      onTap: () {
        // Aquí podrías llamar a tu API para registrar entrada
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entrada registrada')),
        );
        Navigator.pop(context); // volver al dashboard
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF16A34A), Color(0xFF15803D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.login_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Marcar Entrada',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                Text('Registrar inicio de jornada',
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _daySummary() {
    Widget summaryCard(IconData icon, String title, String subtitle) => _cardBox(
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              )
            ],
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text('Resumen del Día',
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600)),
        ),
        Row(
          children: [
            Expanded(child: summaryCard(Icons.calendar_today_rounded, 'Lun', 'Hoy')),
            const SizedBox(width: 10),
            Expanded(child: summaryCard(Icons.login_rounded, '—', 'Pendiente de entrada')),
            const SizedBox(width: 10),
            Expanded(child: summaryCard(Icons.timer_rounded, '0:00', 'Horas')),
          ],
        ),
      ],
    );
  }

  // UI helpers
  Widget _cardBox({required Widget child, EdgeInsets? padding}) => Container(
        padding: padding ?? const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border.withOpacity(0.6)),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 6)),
          ],
        ),
        child: child,
      );

  Widget _divider() => Container(height: 1, color: Colors.white.withOpacity(0.06));

  Widget _pill({required String text, required IconData icon, required Color color}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(children: [Icon(icon, color: Colors.white, size: 16), const SizedBox(width: 6), Text(text, style: const TextStyle(color: Colors.white, fontSize: 12))]),
      );

  Widget _locationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
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
        ]),
      );

  Widget _statusDot(Color color) => Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle));

  String _two(int n) => n.toString().padLeft(2, '0');
  String _dateInSpanish(DateTime d) {
    const dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    const meses = ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
    final dia = dias[d.weekday - 1];
    final mes = meses[d.month - 1];
    return '$dia, ${d.day} de $mes de ${d.year}';
  }
}
