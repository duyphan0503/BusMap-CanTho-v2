import 'package:easy_localization/easy_localization.dart';

/// A utility class for translating operating hours descriptions
/// from OSM format to a localized, human-readable format.
///
/// Example: "Mo-Su 05:00-17:30" becomes "Monday - Sunday 05:00-17:30" in English
/// or "Thứ Hai - Chủ Nhật 05:00-17:30" in Vietnamese.
class OperatingHoursTranslator {
  /// Translates an operating hours description from OSM format
  /// to a localized, human-readable format.
  ///
  /// [hours] The operating hours description in OSM format (e.g., "Mo-Su 05:00-17:30").
  /// Returns localized operating hours string.
  static String translate(String hours) {
    if (hours.isEmpty) return '';

    // Map of English day abbreviations to translation keys
    final Map<String, String> dayMap = {
      'Mo': 'days.monday',
      'Tu': 'days.tuesday',
      'We': 'days.wednesday',
      'Th': 'days.thursday',
      'Fr': 'days.friday',
      'Sa': 'days.saturday',
      'Su': 'days.sunday',
    };

    // First, mark the parts we've already processed to avoid double translations
    final List<String> parts = [];
    String workingCopy = hours;

    // Process day ranges (e.g., "Mo-Fr")
    final RegExp dayRangePattern = RegExp(r'([A-Za-z]{2})-([A-Za-z]{2})');
    final dayRangeMatches = dayRangePattern.allMatches(hours);

    for (final match in dayRangeMatches) {
      final startDay = match.group(1);
      final endDay = match.group(2);
      final fullMatch = match.group(0);

      if (startDay != null &&
          endDay != null &&
          dayMap.containsKey(startDay) &&
          dayMap.containsKey(endDay)) {
        final startDayTranslated = dayMap[startDay]!.tr();
        final endDayTranslated = dayMap[endDay]!.tr();
        final replacement = '$startDayTranslated - $endDayTranslated';

        // Replace this range and mark it as processed
        final startIndex = workingCopy.indexOf(fullMatch!);
        if (startIndex >= 0) {
          final endIndex = startIndex + fullMatch.length;
          workingCopy =
              '${workingCopy.substring(0, startIndex)}__PROCESSED_RANGE_${parts.length}__${workingCopy.substring(endIndex)}';
          parts.add(replacement);
        }
      }
    }

    // Process individual days (e.g., "Mo, We, Fr")
    for (final day in dayMap.keys) {
      final RegExp standaloneDayPattern = RegExp('\\b$day\\b');
      final matches = standaloneDayPattern.allMatches(workingCopy);

      for (final match in matches) {
        final fullMatch = match.group(0);
        if (fullMatch != null) {
          final replacement = dayMap[day]!.tr();

          // Replace this day and mark it as processed
          final startIndex = match.start;
          final endIndex = match.end;
          workingCopy =
              '${workingCopy.substring(0, startIndex)}__PROCESSED_DAY_${parts.length}__${workingCopy.substring(endIndex)}';
          parts.add(replacement);
        }
      }
    }

    // Restore all processed parts
    for (int i = 0; i < parts.length; i++) {
      workingCopy = workingCopy.replaceAll(
        '__PROCESSED_RANGE_${i}__',
        parts[i],
      );
      workingCopy = workingCopy.replaceAll('__PROCESSED_DAY_${i}__', parts[i]);
    }

    return workingCopy;
  }
}
