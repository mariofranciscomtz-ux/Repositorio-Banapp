DateTime _mondayOfIsoWeek(int year, int week) {
  final jan4 = DateTime(year, 1, 4);
  final week1Monday = jan4.subtract(Duration(days: jan4.weekday - 1));
  return week1Monday.add(Duration(days: (week - 1) * 7));
}

int isoWeekNumber(DateTime date) {
  final d = DateTime.utc(date.year, date.month, date.day);
  final thursday = d.add(Duration(days: 4 - d.weekday));
  final jan1 = DateTime.utc(thursday.year, 1, 1);
  final daysSinceJan1 = thursday.difference(jan1).inDays;
  return (daysSinceJan1 / 7).floor() + 1;
}

/// El año de embolse N empieza en la semana ISO 42 del año calendario N-1
/// y termina en la semana ISO 41 del año calendario N.
int embolseYearFor(DateTime fecha) {
  final umbral = _mondayOfIsoWeek(fecha.year, 42);
  return fecha.isBefore(umbral) ? fecha.year : fecha.year + 1;
}

DateTime embolseYearStart(int embolseYear) => _mondayOfIsoWeek(embolseYear - 1, 42);

/// Exclusivo: es el inicio del siguiente año de embolse.
DateTime embolseYearEnd(int embolseYear) => _mondayOfIsoWeek(embolseYear, 42);

/// Fecha en formato yyyy-MM-dd, sin hora. Las columnas `fecha` en la base
/// de datos son de tipo `date` (Postgres) y llegan como texto plano en ese
/// formato — hay que comparar siempre contra el mismo formato, o la
/// comparación de texto falla en los límites exactos de cada semana.
String dateOnly(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}
