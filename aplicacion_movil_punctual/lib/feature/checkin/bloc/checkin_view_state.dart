class CheckInViewState {
  const CheckInViewState();

  String twoDigits(int value) => value.toString().padLeft(2, '0');

  String dateInSpanish(DateTime d) {
    const dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    const meses = [
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
    final dia = dias[d.weekday - 1];
    final mes = meses[d.month - 1];
    return '$dia, ${d.day} de $mes de ${d.year}';
  }
}