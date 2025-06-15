import 'package:easy_localization/easy_localization.dart';

/// Utility class for string manipulation functions
class StringUtils {
  /// Trích xuất phần tên ngắn gọn từ địa chỉ đầy đủ
  /// Chỉ lấy phần trước dấu phẩy đầu tiên
  static String getShortName(String? description) {
    if (description == null || description.isEmpty) return '';
    final firstComma = description.indexOf(',');
    if (firstComma > 0) {
      return description.substring(0, firstComma).trim();
    }
    return description;
  }

  /// Định dạng khoảng cách với đơn vị phù hợp (m hoặc km)
  static String formatDistance(
    double distanceInMeters, {
    bool useShortLabels = false,
  }) {
    if (distanceInMeters < 0) {
      distanceInMeters = 0;
    }

    if (distanceInMeters < 1000) {
      // Hiển thị theo mét nếu nhỏ hơn 1km
      final meters = distanceInMeters.round();
      return useShortLabels
          ? '$meters m'
          : tr('distance_meters', args: [meters.toString()]);
    } else {
      // Hiển thị theo km nếu từ 1km trở lên
      final km = (distanceInMeters / 1000);
      final kmFormatted =
          km < 10 ? km.toStringAsFixed(1) : km.round().toString();
      return useShortLabels
          ? '$kmFormatted km'
          : tr('distance_kilometers', args: [kmFormatted]);
    }
  }

  /// Định dạng thời gian từ số giây
  static String formatDuration(
    int durationInSeconds, {
    bool useShortLabels = false,
  }) {
    if (durationInSeconds < 0) {
      durationInSeconds = 0;
    }

    final hours = durationInSeconds ~/ 3600;
    final minutes = (durationInSeconds % 3600) ~/ 60;

    if (hours == 0) {
      // Chỉ hiển thị phút nếu không có giờ
      return useShortLabels
          ? '$minutes ${tr('min')}'
          : tr('duration_minutes', namedArgs: {'minutes': minutes.toString()});
    } else if (minutes == 0) {
      // Chỉ hiển thị giờ nếu không có phút
      return useShortLabels
          ? '$hours ${tr('hr')}'
          : tr('duration_hours', namedArgs: {'hours': hours.toString()});
    } else {
      // Hiển thị cả giờ và phút
      return useShortLabels
          ? '$hours ${tr('hr')} $minutes ${tr('min')}'
          : tr(
            'duration_hours_minutes',
            namedArgs: {
              'hours': hours.toString(),
              'minutes': minutes.toString(),
            },
          );
    }
  }

  /// Định dạng thời gian từ chuỗi định dạng (như "5 phút", "2 giờ 30 phút")
  static String formatTimeString(String timeString, {bool useEnglish = false}) {
    // Xác định xem chuỗi có chứa "giờ" và "phút" không
    final hasHours = timeString.contains('giờ');
    final hasMinutes = timeString.contains('phút');

    if (!hasHours && !hasMinutes) {
      // Trả về nguyên bản nếu không nhận dạng được định dạng
      return timeString;
    }

    // Trích xuất giờ và phút
    int hours = 0;
    int minutes = 0;

    try {
      if (hasHours) {
        final hourPattern = RegExp(r'(\d+)\s*giờ');
        final hourMatch = hourPattern.firstMatch(timeString);
        if (hourMatch != null && hourMatch.group(1) != null) {
          hours = int.parse(hourMatch.group(1)!);
        }
      }

      if (hasMinutes) {
        final minutePattern = RegExp(r'(\d+)\s*phút');
        final minuteMatch = minutePattern.firstMatch(timeString);
        if (minuteMatch != null && minuteMatch.group(1) != null) {
          minutes = int.parse(minuteMatch.group(1)!);
        }
      }
    } catch (e) {
      return timeString; // Trả về nguyên bản nếu có lỗi trong quá trình parse
    }

    // Xây dựng chuỗi kết quả dựa trên ngôn ngữ
    if (useEnglish) {
      if (hours > 0 && minutes > 0) {
        return '$hours hr $minutes min';
      } else if (hours > 0) {
        return '$hours ${hours == 1 ? 'hour' : 'hours'}';
      } else {
        return '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
      }
    } else {
      return timeString; // Giữ nguyên nếu là tiếng Việt
    }
  }

  /// Chuyển đổi khoảng cách từ chuỗi sang giá trị số mét
  static double parseDistance(String distanceStr) {
    try {
      // Loại bỏ khoảng trắng và chuyển về chữ thường
      final cleanStr = distanceStr.toLowerCase().replaceAll(' ', '');

      // Tìm số trong chuỗi
      final numMatch = RegExp(r'(\d+[.,]?\d*)').firstMatch(cleanStr);
      if (numMatch == null) return 0;

      final numStr = numMatch.group(1)!.replaceAll(',', '.');
      final distance = double.parse(numStr);

      // Xác định đơn vị (m hoặc km)
      if (cleanStr.contains('km')) {
        return distance * 1000; // Chuyển km thành mét
      } else {
        return distance; // Giả sử mặc định là mét
      }
    } catch (e) {
      return 0;
    }
  }
}
