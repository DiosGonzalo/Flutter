class DashboardSummaryItem {
  final String title;
  final String detail;
  final String status;

  const DashboardSummaryItem({
    required this.title,
    required this.detail,
    required this.status,
  });
}

class DashboardData {
  final String employeeName;
  final bool isPresent;
  final String entryFrom;
  final String hoursTodayText;
  final double hoursWeek;
  final double progressPercent;
  final String actionEntryLabel;
  final List<DashboardSummaryItem> summaryItems;

  const DashboardData({
    required this.employeeName,
    required this.isPresent,
    required this.entryFrom,
    required this.hoursTodayText,
    required this.hoursWeek,
    required this.progressPercent,
    required this.actionEntryLabel,
    required this.summaryItems,
  });
}
