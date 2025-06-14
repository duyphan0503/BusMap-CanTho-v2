
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
}
