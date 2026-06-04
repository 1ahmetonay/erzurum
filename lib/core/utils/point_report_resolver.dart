import '../../models/point_report_model.dart';

bool isWithinReportCooldown(
  DateTime? lastReportAt,
  DateTime now,
  Duration cooldown,
) {
  if (lastReportAt == null) return false;
  return now.difference(lastReportAt) < cooldown;
}

bool isValidReportType(String type) {
  return PointReportTypes.values.contains(type);
}

String reportTypeLabel(String type) {
  return switch (type) {
    PointReportTypes.broken => 'Bozuk',
    PointReportTypes.full => 'Dolu',
    PointReportTypes.missing => 'Eksik',
    PointReportTypes.wrongLocation => 'Konum yanlış',
    PointReportTypes.other => 'Diğer',
    _ => 'Bilinmeyen',
  };
}
