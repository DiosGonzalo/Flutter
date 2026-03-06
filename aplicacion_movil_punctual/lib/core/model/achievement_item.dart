class AchievementItem {
  final String title;
  final String subtitle;
  final String date;

  const AchievementItem({
    required this.title,
    this.subtitle = '',
    this.date = '',
  });
}