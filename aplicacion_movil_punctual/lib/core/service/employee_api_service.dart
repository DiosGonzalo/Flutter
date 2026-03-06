import 'package:aplicacion_movil_punctual/core/dto/weekly_stats_dto.dart';
import 'package:aplicacion_movil_punctual/core/model/achievement_item.dart';
import 'package:aplicacion_movil_punctual/core/model/attendance_status_data.dart';
import 'package:aplicacion_movil_punctual/core/model/dashboard_data.dart';
import 'package:aplicacion_movil_punctual/core/model/profile_data.dart';
import 'package:aplicacion_movil_punctual/core/model/schedule_day.dart';
import 'package:aplicacion_movil_punctual/core/model/schedule_screen_data.dart';
import 'package:aplicacion_movil_punctual/core/service/api_client.dart';
import 'package:flutter/foundation.dart';

class EmployeeApiService {
  final ApiClient _apiClient;

  EmployeeApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<DashboardData> fetchDashboard() async {
    final data = await _getWithFallback(['/employee/dashboard-screen', '/dashboard-screen', '/dashboard']);

    final saludo = _asMap(data['saludo']);
    final jornada = _asMap(data['jornada']);
    final acciones = _asList(data['acciones']);
    final resumen = _asList(data['resumen_hoy']);

    final actionEntry = acciones
        .map(_asMap)
        .firstWhere((item) => item['key']?.toString() == 'entrada', orElse: () => const <String, dynamic>{});

    final summaryItems = resumen.map((item) {
      final map = _asMap(item);
      return DashboardSummaryItem(
        title: map['titulo']?.toString() ?? '',
        detail: map['detalle']?.toString() ?? '',
        status: map['estado']?.toString() ?? 'idle',
      );
    }).toList();

    return DashboardData(
      employeeName: saludo['nombre']?.toString() ?? 'Empleado',
      isPresent: jornada['is_presente'] == true,
      entryFrom: jornada['entrada_desde']?.toString() ?? '--:--',
      hoursTodayText: jornada['horas_hoy_texto']?.toString() ?? '0h 00m',
      hoursWeek: _asDouble(jornada['horas_semana']),
      progressPercent: _asDouble(jornada['progreso_hoy_pct']),
      actionEntryLabel: actionEntry['label']?.toString() ?? 'Marcar entrada',
      summaryItems: summaryItems,
    );
  }

  Future<AttendanceStatusData> fetchAttendanceStatus() async {
    final data = await _getWithFallback(['/employee/attendance-screen', '/attendance-screen', '/attendance-status']);
    final sesion = _asMap(data['sesion']);
    final ubicacion = _asMap(data['ubicacion']);
    final resumenDia = _asMap(data['resumen_dia']);

    return AttendanceStatusData(
      now: data['ahora']?.toString() ?? '--:--:--',
      date: data['fecha']?.toString() ?? '',
      active: sesion['activa'] == true,
      activeSince: sesion['desde']?.toString() ?? '--:--',
      workedHours: sesion['horas_trabajadas']?.toString() ?? '0h 00m',
      entryToday: sesion['entrada_hoy']?.toString() ?? '--:--',
      exitToday: sesion['salida_hoy']?.toString() ?? '--:--',
      workplace: ubicacion['workplace']?.toString() ?? 'No asignado',
      wifiOk: ubicacion['wifi_ok'] == true,
      gpsOk: ubicacion['gps_ok'] == true,
      dayShort: resumenDia['dia']?.toString() ?? '',
    );
  }

  Future<void> checkIn() async {
    await _postWithFallback(['/employee/check-in', '/check-in']);
  }

  Future<void> checkOut() async {
    await _postWithFallback(['/employee/check-out', '/check-out']);
  }

  Future<ScheduleScreenData> fetchScheduleScreen({int weekOffset = 0}) async {
    const basePaths = ['/employee/schedule-screen', '/schedule-screen'];

    final data = weekOffset == 0 ? await _getWithFallback(basePaths) : await _getScheduleForOffset(basePaths, weekOffset);

    _debugSchedulePayload(data, weekOffset);

    final semana = _asMap(data['semana']);
    if (weekOffset != 0 && _responseLooksLikeCurrentWeek(data, semana)) {
      throw const ApiException(
        422,
        'El servidor devolvio la semana actual. No se pudo cargar la semana seleccionada.',
      );
    }

    final estadisticas = _asMap(semana['estadisticas']);
    final dias = _asList(semana['dias']);
    final mes = _asMap(data['mes']);
    final resumen = _asMap(mes['resumen']);
    final hasAssignedSchedule = _hasAssignedSchedule(data) || _hasAssignedSchedule(semana);
    final defaultSchedule = _firstValidSchedule([
      _extractNamedScheduleText(semana),
      _extractNamedScheduleText(data),
      _extractScheduleRange(semana),
      _extractScheduleRange(data),
      _buildScheduleRange(
        _firstNonEmpty([
          semana['hora_entrada'],
          semana['entrada_desde'],
          semana['hora_inicio'],
          data['hora_entrada'],
          data['entrada_desde'],
          data['hora_inicio'],
        ]),
        _firstNonEmpty([
          semana['hora_salida'],
          semana['salida_hasta'],
          semana['hora_fin'],
          data['hora_salida'],
          data['salida_hasta'],
          data['hora_fin'],
        ]),
      ),
      hasAssignedSchedule ? 'Horario asignado' : 'Sin horario',
    ]);

    final dayEntries = dias.asMap().entries;
    final days = dayEntries.map((entryWithIndex) {
      final dayIndex = entryWithIndex.key;
      final day = _asMap(entryWithIndex.value);
      final status = day['estado']?.toString() ?? '';
      final nonWorkingDay = _isNonWorkingDay(day, status: status, dayIndex: dayIndex, totalDays: dias.length);
      final scheduleRange = _firstValidSchedule([
        _extractNamedScheduleText(day),
        _extractScheduleRange(day),
        day['horario_asignado'],
        day['horario_laboral'],
        day['schedule'],
        day['schedule_text'],
        day['horario'],
        day['horario_texto'],
        day['turno'],
        day['jornada'],
        _buildScheduleRange(
          _firstNonEmpty([day['hora_inicio'], day['entrada_desde'], day['inicio_jornada']]),
          _firstNonEmpty([day['hora_fin'], day['salida_hasta'], day['fin_jornada']]),
        ),
        defaultSchedule,
        'Sin horario',
      ]);

      final entry = _firstNonEmpty([
        day['entrada'],
        day['hora_entrada'],
        day['entrada_hoy'],
        day['check_in'],
      ]);

      final exit = _firstNonEmpty([
        day['salida'],
        day['hora_salida'],
        day['salida_hoy'],
        day['check_out'],
      ]);

      final workedHours = nonWorkingDay
          ? '--'
          : _firstNonEmpty([
              _resolveDayHours(day, entry: entry, exit: exit),
              hasAssignedSchedule ? '' : '0h',
            ]);

      final plannedHours = nonWorkingDay
          ? '--'
          : _firstNonEmpty([
              _hoursBetween(
                _firstNonEmpty([day['hora_inicio'], day['entrada_desde'], day['inicio_jornada']]),
                _firstNonEmpty([day['hora_fin'], day['salida_hasta'], day['fin_jornada']]),
              ),
              _hoursBetween(
                _firstNonEmpty([semana['hora_entrada'], semana['entrada_desde'], semana['hora_inicio']]),
                _firstNonEmpty([semana['hora_salida'], semana['salida_hasta'], semana['hora_fin']]),
              ),
              hasAssignedSchedule ? '' : '0h',
            ]);

      return ScheduleDay(
        day: _asInt(day['numero']),
        statusLabel: _statusLabel(status),
        title: scheduleRange,
        subtitle: 'Entrada: ${entry.isEmpty ? '--:--' : entry}\nSalida: ${exit.isEmpty ? '--:--' : exit}',
        plannedHours: plannedHours,
        workedHours: workedHours,
        completed: status == 'complete',
        late: status == 'late',
      );
    }).toList();

    final weekly = WeeklyStatsDto(
      totalHours: '${_asDouble(estadisticas['total_horas']).toStringAsFixed(2)}h',
      averageHours: estadisticas['promedio_entrada']?.toString() ?? '--:--',
      attendance: '${_asInt(estadisticas['asistencia_pct'])}%',
      workedDays: _asInt(estadisticas['dias_asistidos']),
    );

    final monthlySummary = MonthlyScheduleSummary(
      workedDays: _asInt(resumen['dias_laborados']),
      totalDays: _asInt(resumen['dias_totales']),
      totalHours: '${_asDouble(resumen['total_horas']).toStringAsFixed(2)}h',
      punctualityPct: _asInt(resumen['puntualidad_pct']),
    );

    return ScheduleScreenData(
      weeklyStats: weekly,
      days: days,
      monthlySummary: monthlySummary,
    );
  }

  Future<ProfileData> fetchProfile() async {
    final data = await _getWithFallback(['/employee/profile-screen', '/profile-screen', '/profile']);

    final usuario = _asMap(data['usuario']).isNotEmpty ? _asMap(data['usuario']) : _asMap(data['user']);
    final esteMes = _asMap(data['este_mes']).isNotEmpty ? _asMap(data['este_mes']) : _asMap(data['mes_actual']);
    final resumenAnual = _asMap(data['resumen_anual']).isNotEmpty ? _asMap(data['resumen_anual']) : _asMap(data['anual']);
    final balance = _asMap(data['balance_permisos']).isNotEmpty ? _asMap(data['balance_permisos']) : _asMap(data['permisos']);

    final vacations = _permission(_firstNonEmptyMap([balance['vacaciones'], balance['vacation']]));
    final personal = _permission(_firstNonEmptyMap([balance['dias_personales'], balance['personales'], balance['personal_days']]));
    final medical = _permission(_firstNonEmptyMap([balance['permisos_medicos'], balance['medicos'], balance['medical_leaves']]));

    final achievements = _asList(data['logros']).isNotEmpty
        ? _asList(data['logros'])
        : _asList(data['achievements']);

    final cleanAchievements = achievements
        .map((item) => _asMap(item))
        .where((item) => _firstNonEmpty([item['titulo'], item['title']]).isNotEmpty)
        .map(
          (item) => AchievementItem(
            title: _firstNonEmpty([item['titulo'], item['title']]),
            subtitle: _firstNonEmpty([item['detalle'], item['subtitle'], item['description']]),
            date: _firstNonEmpty([item['fecha'], item['date']]),
          ),
        )
        .toList();

    return ProfileData(
      fullName: _firstNonEmpty([usuario['nombre'], usuario['full_name'], usuario['name'], data['nombre']]),
      role: _firstNonEmpty([usuario['rol'], usuario['role'], data['rol']]),
      email: _firstNonEmpty([usuario['email'], usuario['correo'], data['email']]),
      phone: _firstNonEmpty([usuario['telefono'], usuario['phone'], data['telefono']]),
      department: _firstNonEmpty([usuario['departamento'], usuario['department'], data['departamento']]),
      workplace: _firstNonEmpty([usuario['workplace'], usuario['sede'], data['workplace']]),
      schedule: _firstNonEmpty([
        usuario['horario_asignado'],
        usuario['horario_texto'],
        usuario['horario'],
        usuario['schedule'],
        data['horario_asignado'],
        data['horario_texto'],
      ]),
      punctuality: _resolvePunctuality(esteMes, data),
      monthlyCompliance: _resolveMonthlyCompliance(esteMes, data),
      annualAttendance: _resolveAnnualAttendance(resumenAnual, data),
      vacations: vacations,
      personalDays: personal,
      medicalLeaves: medical,
      achievements: cleanAchievements,
    );
  }

  Future<Map<String, dynamic>> _getWithFallback(List<String> paths) async {
    ApiException? lastError;
    for (final path in paths) {
      try {
        return await _apiClient.get(path);
      } on ApiException catch (error) {
        lastError = error;
        if (error.statusCode != 404) {
          rethrow;
        }
      }
    }
    throw lastError ?? const ApiException(404, 'Endpoint no encontrado');
  }

  Future<Map<String, dynamic>> _postWithFallback(List<String> paths) async {
    ApiException? lastError;
    for (final path in paths) {
      try {
        return await _apiClient.post(path);
      } on ApiException catch (error) {
        lastError = error;
        if (error.statusCode != 404) {
          rethrow;
        }
      }
    }
    throw lastError ?? const ApiException(404, 'Endpoint no encontrado');
  }

  Future<Map<String, dynamic>> _getScheduleForOffset(List<String> basePaths, int weekOffset) async {
    final weekRange = _weekRangeForOffset(weekOffset);
    final weekStart = _toIsoDate(weekRange.start);
    final weekEnd = _toIsoDate(weekRange.end);

    const dateRangeQueryPairs = [
      ('week_start', 'week_end'),
      ('start_date', 'end_date'),
      ('fecha_inicio', 'fecha_fin'),
      ('from', 'to'),
      ('inicio', 'fin'),
    ];

    const singleDateKeys = [
      'date',
      'fecha',
      'reference_date',
      'week_date',
      'weekStart',
      'week_start',
    ];

    const queryKeys = [
      'week_offset',
      'weekOffset',
      'offset',
      'semana_offset',
      'semanaOffset',
      'week',
      'weeks_ago',
      'weeksAgo',
    ];

    final candidateValues = <int>{weekOffset};
    // Some APIs expect previous weeks as a positive count instead of negatives.
    if (weekOffset < 0) {
      candidateValues.add(weekOffset.abs());
    }

    ApiException? lastError;

    for (final path in basePaths) {
      for (final candidateValue in candidateValues) {
        final pathVariants = [
          '$path/$candidateValue',
          '$path/week/$candidateValue',
          '$path/semana/$candidateValue',
          '$path/$weekStart',
          '$path/week/$weekStart',
          '$path/semana/$weekStart',
        ];

        for (final variant in pathVariants) {
          try {
            final result = await _apiClient.get(variant);
            if (kDebugMode) {
              debugPrint('[SCHEDULE_DEBUG] query success: $variant');
            }
            return result;
          } on ApiException catch (error) {
            lastError = error;
            if (_isRetryableScheduleVariantError(error)) {
              continue;
            }
            rethrow;
          }
        }
      }

      for (final queryPair in dateRangeQueryPairs) {
        final dateRangePath = '$path?${queryPair.$1}=$weekStart&${queryPair.$2}=$weekEnd';
        try {
          final result = await _apiClient.get(dateRangePath);
          if (kDebugMode) {
            debugPrint('[SCHEDULE_DEBUG] query success: $dateRangePath');
          }
          return result;
        } on ApiException catch (error) {
          lastError = error;
          if (_isRetryableScheduleVariantError(error)) {
            continue;
          }
          rethrow;
        }
      }

      for (final singleDateKey in singleDateKeys) {
        final singleDatePath = '$path?$singleDateKey=$weekStart';
        try {
          final result = await _apiClient.get(singleDatePath);
          if (kDebugMode) {
            debugPrint('[SCHEDULE_DEBUG] query success: $singleDatePath');
          }
          return result;
        } on ApiException catch (error) {
          lastError = error;
          if (_isRetryableScheduleVariantError(error)) {
            continue;
          }
          rethrow;
        }
      }

      for (final queryKey in queryKeys) {
        for (final candidateValue in candidateValues) {
          final offsetPath = '$path?$queryKey=$candidateValue';
          try {
            final result = await _apiClient.get(offsetPath);
            if (kDebugMode) {
              debugPrint('[SCHEDULE_DEBUG] query success: $offsetPath');
            }
            return result;
          } on ApiException catch (error) {
            lastError = error;
            if (_isRetryableScheduleVariantError(error)) {
              continue;
            }
            rethrow;
          }
        }
      }
    }

    throw lastError ?? const ApiException(404, 'Endpoint de horario por semana no encontrado');
  }

  bool _isRetryableScheduleVariantError(ApiException error) {
    return error.statusCode == 400 ||
        error.statusCode == 404 ||
        error.statusCode == 422 ||
        error.statusCode == 500 ||
        error.statusCode == 502;
  }

  ({DateTime start, DateTime end}) _weekRangeForOffset(int weekOffset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfCurrentWeek = today.subtract(Duration(days: today.weekday - 1));
    final start = startOfCurrentWeek.add(Duration(days: weekOffset * 7));
    final end = start.add(const Duration(days: 6));
    return (start: start, end: end);
  }

  bool _responseLooksLikeCurrentWeek(Map<String, dynamic> root, Map<String, dynamic> semana) {
    final currentRange = _weekRangeForOffset(0);
    final expectedStart = _toIsoDate(currentRange.start);
    final expectedEnd = _toIsoDate(currentRange.end);

    final start = _extractIsoDate([root, semana], [
      'week_start',
      'start_date',
      'fecha_inicio',
      'inicio',
      'desde',
      'semana_inicio',
    ]);

    final end = _extractIsoDate([root, semana], [
      'week_end',
      'end_date',
      'fecha_fin',
      'fin',
      'hasta',
      'semana_fin',
    ]);

    if (start.isEmpty && end.isEmpty) {
      return false;
    }

    final sameStart = start.isEmpty || start == expectedStart;
    final sameEnd = end.isEmpty || end == expectedEnd;
    return sameStart && sameEnd;
  }

  String _extractIsoDate(List<Map<String, dynamic>> maps, List<String> keys) {
    for (final map in maps) {
      for (final key in keys) {
        final raw = map[key]?.toString().trim() ?? '';
        if (raw.isEmpty) {
          continue;
        }

        final parsed = DateTime.tryParse(raw);
        if (parsed != null) {
          return _toIsoDate(DateTime(parsed.year, parsed.month, parsed.day));
        }

        final dateMatch = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(raw);
        if (dateMatch != null) {
          return '${dateMatch.group(1)}-${dateMatch.group(2)}-${dateMatch.group(3)}';
        }
      }
    }
    return '';
  }

  String _toIsoDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  PermissionBalance _permission(dynamic raw) {
    final map = _asMap(raw);
    return PermissionBalance(
      used: _asInt(_firstNonEmpty([map['usados'], map['used'], map['consumidos']])),
      total: _asInt(_firstNonEmpty([map['total'], map['available'], map['disponibles']])),
    );
  }

  Map<String, dynamic> _firstNonEmptyMap(List<dynamic> values) {
    for (final value in values) {
      final map = _asMap(value);
      if (map.isNotEmpty) {
        return map;
      }
    }
    return <String, dynamic>{};
  }

  String _percentText(List<dynamic> values) {
    for (final value in values) {
      if (value == null) {
        continue;
      }

      final asText = value.toString().trim();
      if (asText.isEmpty || asText.toLowerCase() == 'null') {
        continue;
      }

      if (asText.endsWith('%')) {
        return asText;
      }

      final numeric = num.tryParse(asText);
      if (numeric != null) {
        final normalized = numeric > 0 && numeric <= 1 ? numeric * 100 : numeric;
        return '${normalized.round()}%';
      }
    }

    return '--';
  }

  String _resolvePunctuality(Map<String, dynamic> month, Map<String, dynamic> root) {
    final direct = _percentText([
      month['puntualidad_pct'],
      month['punctuality_pct'],
      month['puntualidad'],
      root['puntualidad_pct'],
      root['punctuality_pct'],
    ]);

    final computed = _percentFromFraction(
      _firstNonEmpty([month['dias_a_tiempo'], month['on_time_days'], month['a_tiempo']]),
      _firstNonEmpty([
        month['dias_asistidos'],
        month['attended_days'],
        month['dias_laborados'],
        month['working_days'],
      ]),
    );

    final byLateDays = _percentFromLateDays(
      _firstNonEmpty([
        month['llegadas_tarde'],
        month['late_days'],
      ]),
      _firstNonEmpty([
        month['dias_asistidos'],
        month['attended_days'],
        month['dias_laborados'],
        month['working_days'],
      ]),
    );

    return _firstNonEmpty([computed, byLateDays, direct, '--']);
  }

  String _resolveMonthlyCompliance(Map<String, dynamic> month, Map<String, dynamic> root) {
    final direct = _percentText([
      month['cumplimiento_pct'],
      month['productividad_pct'],
      month['compliance_pct'],
      root['cumplimiento_pct'],
      root['productividad_pct'],
    ]);

    final byHours = _percentFromFraction(
      _firstNonEmpty([
        month['horas_trabajadas'],
        month['worked_hours'],
        month['horas_realizadas'],
      ]),
      _firstNonEmpty([
        month['horas_objetivo'],
        month['target_hours'],
        month['horas_esperadas'],
        month['expected_hours'],
      ]),
    );

    final byDays = _percentFromFraction(
      _firstNonEmpty([
        month['dias_cumplidos'],
        month['compliant_days'],
      ]),
      _firstNonEmpty([
        month['dias_laborados'],
        month['working_days'],
      ]),
    );

    return _firstNonEmpty([byHours, byDays, direct, '--']);
  }

  String _resolveAnnualAttendance(Map<String, dynamic> annual, Map<String, dynamic> root) {
    final direct = _percentText([
      annual['asistencia_pct'],
      annual['attendance_pct'],
      annual['puntualidad_pct'],
      root['asistencia_pct'],
      root['attendance_pct'],
    ]);

    final computed = _percentFromFraction(
      _firstNonEmpty([
        annual['dias_asistidos'],
        annual['attended_days'],
      ]),
      _firstNonEmpty([
        annual['dias_totales'],
        annual['total_days'],
        annual['dias_laborables'],
        annual['working_days'],
      ]),
    );

    return _firstNonEmpty([computed, direct, '--']);
  }

  String _percentFromFraction(dynamic numeratorRaw, dynamic denominatorRaw) {
    final numerator = _asDouble(numeratorRaw);
    final denominator = _asDouble(denominatorRaw);
    if (denominator <= 0 || numerator < 0) {
      return '';
    }
    final pct = (numerator / denominator) * 100;
    return '${pct.clamp(0, 100).round()}%';
  }

  String _percentFromLateDays(dynamic lateRaw, dynamic totalRaw) {
    final late = _asDouble(lateRaw);
    final total = _asDouble(totalRaw);
    if (total <= 0 || late < 0) {
      return '';
    }
    final onTime = ((total - late) / total) * 100;
    return '${onTime.clamp(0, 100).round()}%';
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    return <String, dynamic>{};
  }

  List<dynamic> _asList(dynamic value) {
    if (value is List<dynamic>) {
      return value;
    }
    return <dynamic>[];
  }

  int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _asDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'complete':
        return 'Completo';
      case 'late':
        return 'Llegada tarde';
      case 'descanso':
        return 'Descanso';
      case 'ausente':
        return 'Ausente';
      default:
        return 'Pendiente';
    }
  }

  String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty && text != 'null') {
        return text;
      }
    }
    return '';
  }

  String _buildScheduleRange(String start, String end) {
    if (start.isEmpty && end.isEmpty) {
      return '';
    }
    return '${start.isEmpty ? '--:--' : start} - ${end.isEmpty ? '--:--' : end}';
  }

  bool _hasAssignedSchedule(Map<String, dynamic> source) {
    if (source.isEmpty) {
      return false;
    }

    if (source['tiene_horario'] == true || source['has_schedule'] == true || source['schedule_assigned'] == true) {
      return true;
    }

    return _firstValidSchedule([
          source['horario_asignado'],
          source['horario_laboral'],
          source['horario_texto'],
          source['horario_nombre'],
          source['nombre_horario'],
          source['schedule_name'],
          source['schedule_text'],
          source['assigned_schedule_text'],
          source['hora_entrada'],
          source['hora_salida'],
          _extractNamedScheduleText(source),
          _extractScheduleRange(source),
        ])
        .isNotEmpty;
  }

  String _extractScheduleRange(Map<String, dynamic> source) {
    if (source.isEmpty) {
      return '';
    }

    final horario = _asMap(source['horario']);
    final jornada = _asMap(source['jornada']);
    final turno = _asMap(source['turno']);

    return _firstValidSchedule([
      source['horario_texto'],
      source['horario_asignado'],
      source['horario_laboral'],
      source['rango_horario'],
      source['schedule'],
      source['schedule_text'],
      source['assigned_schedule_text'],
      source['schedule_range'],
      _buildScheduleRange(
        _firstNonEmpty([
          horario['entrada'],
          horario['inicio'],
          horario['hora_entrada'],
          horario['start_time'],
          horario['startTime'],
          horario['entry_time'],
          jornada['entrada'],
          jornada['inicio'],
          jornada['start_time'],
          jornada['startTime'],
          turno['entrada'],
          turno['start_time'],
          turno['startTime'],
          source['hora_entrada'],
          source['entrada_desde'],
          source['hora_inicio'],
          source['start_time'],
          source['startTime'],
        ]),
        _firstNonEmpty([
          horario['salida'],
          horario['fin'],
          horario['hora_salida'],
          horario['end_time'],
          horario['endTime'],
          horario['exit_time'],
          jornada['salida'],
          jornada['fin'],
          jornada['end_time'],
          jornada['endTime'],
          turno['salida'],
          turno['end_time'],
          turno['endTime'],
          source['hora_salida'],
          source['salida_hasta'],
          source['hora_fin'],
          source['end_time'],
          source['endTime'],
        ]),
      ),
    ]);
  }

  String _extractNamedScheduleText(Map<String, dynamic> source) {
    if (source.isEmpty) {
      return '';
    }

    final assigned = _asMap(source['assigned_schedule']);
    final assignedAlt = _asMap(source['schedule_assigned']);
    final template = _asMap(source['schedule_template']);
    final templateAlt = _asMap(source['template']);
    final horarioObj = _asMap(source['horario_obj']);
    final horarioAsignadoObj = _asMap(source['horario_asignado_obj']);

    final scheduleName = _firstValidSchedule([
      source['schedule_name'],
      source['nombre_horario'],
      source['horario_nombre'],
      assigned['name'],
      assigned['nombre'],
      assignedAlt['name'],
      assignedAlt['nombre'],
      template['name'],
      template['nombre'],
      templateAlt['name'],
      templateAlt['nombre'],
      horarioObj['name'],
      horarioObj['nombre'],
      horarioAsignadoObj['name'],
      horarioAsignadoObj['nombre'],
    ]);

    final start = _firstNonEmpty([
      source['hora_inicio'],
      source['hora_entrada'],
      source['start_time'],
      source['startTime'],
      assigned['hora_inicio'],
      assigned['hora_entrada'],
      assigned['start_time'],
      assigned['startTime'],
      assignedAlt['hora_inicio'],
      assignedAlt['hora_entrada'],
      assignedAlt['start_time'],
      assignedAlt['startTime'],
      template['hora_inicio'],
      template['start_time'],
      template['startTime'],
      templateAlt['hora_inicio'],
      templateAlt['start_time'],
      templateAlt['startTime'],
    ]);

    final end = _firstNonEmpty([
      source['hora_fin'],
      source['hora_salida'],
      source['end_time'],
      source['endTime'],
      assigned['hora_fin'],
      assigned['hora_salida'],
      assigned['end_time'],
      assigned['endTime'],
      assignedAlt['hora_fin'],
      assignedAlt['hora_salida'],
      assignedAlt['end_time'],
      assignedAlt['endTime'],
      template['hora_fin'],
      template['end_time'],
      template['endTime'],
      templateAlt['hora_fin'],
      templateAlt['end_time'],
      templateAlt['endTime'],
    ]);

    if (scheduleName.isEmpty) {
      return _buildScheduleRange(start, end);
    }

    if (start.isEmpty && end.isEmpty) {
      return scheduleName;
    }

    return '$scheduleName (${_buildScheduleRange(start, end)})';
  }

  String _firstValidSchedule(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (!_isUnassignedScheduleText(text)) {
        return text;
      }
    }
    return '';
  }

  bool _isUnassignedScheduleText(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty || normalized == 'null') {
      return true;
    }

    const placeholders = {
      '--:-- - --:--',
      'sin horario',
      'sin horario asignado',
      'horario no asignado',
      'no asignado',
      'n/a',
      'na',
      '-',
      '--',
    };

    return placeholders.contains(normalized);
  }

  String _formatHours(dynamic raw) {
    if (raw == null) {
      return '';
    }

    final asText = raw.toString().trim();
    if (asText.isEmpty) {
      return '';
    }

    final parsed = double.tryParse(asText);
    if (parsed == null) {
      return asText;
    }

    final compact = parsed % 1 == 0 ? parsed.toStringAsFixed(0) : parsed.toStringAsFixed(2);
    return '${compact}h';
  }

  String _resolveDayHours(
    Map<String, dynamic> day, {
    required String entry,
    required String exit,
  }) {
    final explicitHours = _positiveHoursFromValues([
      day['horas_trabajadas'],
      day['worked_hours'],
      day['hours_worked'],
      day['horas'],
      day['total_horas'],
      day['horas_texto'],
    ]);
    if (explicitHours.isNotEmpty) {
      return explicitHours;
    }

    final workedByCheckIn = _hoursBetween(entry, exit);
    if (workedByCheckIn.isNotEmpty) {
      return workedByCheckIn;
    }

    final plannedBySchedule = _hoursBetween(
      _firstNonEmpty([day['hora_inicio'], day['entrada_desde'], day['inicio_jornada']]),
      _firstNonEmpty([day['hora_fin'], day['salida_hasta'], day['fin_jornada']]),
    );
    if (plannedBySchedule.isNotEmpty) {
      return plannedBySchedule;
    }

    return '';
  }

  bool _isNonWorkingDay(
    Map<String, dynamic> day, {
    required String status,
    required int dayIndex,
    required int totalDays,
  }) {
    final normalizedStatus = status.trim().toLowerCase();
    const nonWorkingStatuses = {
      'descanso',
      'libre',
      'off',
      'day_off',
      'vacaciones',
      'feriado',
      'holiday',
      'ausente',
    };
    if (nonWorkingStatuses.contains(normalizedStatus)) {
      return true;
    }

    if (day['es_descanso'] == true || day['is_day_off'] == true || day['laborable'] == false) {
      return true;
    }

    // When API returns 7 ordered days (Mon..Sun), positions 5 and 6 are weekend.
    if (totalDays == 7 && dayIndex >= 5) {
      return true;
    }

    return false;
  }

  String _positiveHoursFromValues(List<dynamic> values) {
    for (final value in values) {
      final normalized = _formatHours(value);
      if (normalized.isEmpty) {
        continue;
      }

      final numeric = double.tryParse(normalized.replaceAll('h', '')) ?? 0;
      if (numeric > 0) {
        return normalized;
      }
    }
    return '';
  }

  String _hoursBetween(String start, String end) {
    final startMinutes = _timeToMinutes(start);
    final endMinutes = _timeToMinutes(end);
    if (startMinutes == null || endMinutes == null) {
      return '';
    }

    var diff = endMinutes - startMinutes;
    if (diff <= 0) {
      diff += 24 * 60;
    }

    if (diff <= 0) {
      return '';
    }

    final hours = diff / 60;
    final compact = hours % 1 == 0 ? hours.toStringAsFixed(0) : hours.toStringAsFixed(1);
    return '${compact}h';
  }

  int? _timeToMinutes(String raw) {
    final text = raw.trim().toLowerCase();
    if (text.isEmpty || text == '--:--') {
      return null;
    }

    final clean = text.replaceAll('.', ':').replaceAll(' ', '');
    final match = RegExp(r'^(\d{1,2})(?::(\d{2}))?(am|pm)?$').firstMatch(clean);
    if (match == null) {
      return null;
    }

    var hour = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '0');
    final suffix = match.group(3);
    if (hour == null || minute == null || minute < 0 || minute > 59) {
      return null;
    }

    if (suffix != null) {
      if (hour < 1 || hour > 12) {
        return null;
      }
      if (suffix == 'am') {
        hour = hour == 12 ? 0 : hour;
      } else {
        hour = hour == 12 ? 12 : hour + 12;
      }
    }

    if (hour < 0 || hour > 23) {
      return null;
    }

    return hour * 60 + minute;
  }

  void _debugSchedulePayload(Map<String, dynamic> data, int weekOffset) {
    if (!kDebugMode) {
      return;
    }

    final semana = _asMap(data['semana']);
    final dias = _asList(semana['dias']);
    final firstDay = dias.isNotEmpty ? _asMap(dias.first) : <String, dynamic>{};

    debugPrint('[SCHEDULE_DEBUG] weekOffset=$weekOffset');
    debugPrint('[SCHEDULE_DEBUG] top.hora_entrada=${data['hora_entrada']} top.hora_salida=${data['hora_salida']}');
    debugPrint('[SCHEDULE_DEBUG] semana.hora_entrada=${semana['hora_entrada']} semana.hora_salida=${semana['hora_salida']}');
    debugPrint('[SCHEDULE_DEBUG] semana.horario=${semana['horario']} semana.horario_texto=${semana['horario_texto']}');
    debugPrint('[SCHEDULE_DEBUG] dias.count=${dias.length}');
    debugPrint('[SCHEDULE_DEBUG] dia0.horario=${firstDay['horario']} dia0.horario_texto=${firstDay['horario_texto']}');
    debugPrint('[SCHEDULE_DEBUG] dia0.horario_asignado=${firstDay['horario_asignado']} dia0.schedule=${firstDay['schedule']}');
  }
}
