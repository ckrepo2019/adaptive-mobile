double clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);

String percentText(double progress) => '${(clamp01(progress) * 100).round()}%';

String twoLevelLabel(
  int first,
  String firstLabel,
  int second,
  String secondLabel,
) {
  return '$first $firstLabel • $second $secondLabel';
}
