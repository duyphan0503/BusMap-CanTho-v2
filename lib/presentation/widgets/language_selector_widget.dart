import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectorWidget extends StatelessWidget {
  final VoidCallback? onLanguageChanged;
  final bool isDisabled;

  const LanguageSelectorWidget({
    super.key,
    this.onLanguageChanged,
    this.isDisabled = false,
  });

  static const Map<String, String> _languageCodes = {
    'en': 'english',
    'vi': 'vietnamese',
  };

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: isDisabled ? null : () => _showLanguageDialog(context),
      icon: const Icon(Icons.language),
      tooltip: 'selectLanguage'.tr(),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => SimpleDialog(
            title: Text('selectLanguage'.tr()),
            children:
                _languageCodes.entries
                    .map(
                      (e) => SimpleDialogOption(
                        onPressed: () => _changeLanguage(dialogContext, e.key),
                        child: Row(children: [Text(e.value.tr())]),
                      ),
                    )
                    .toList(),
          ),
    );
  }

  Future<void> _changeLanguage(BuildContext context, String languageCode) async {
    final navigator = Navigator.of(context);

    try {
      // Lưu vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setString('locale', languageCode),
        if (prefs.containsKey('last_login_time'))
          prefs.setInt('last_login_time', DateTime.now().millisecondsSinceEpoch),
      ]);

      // Thay đổi ngôn ngữ
      await context.setLocale(Locale(languageCode));


      // Đóng dialog và gọi callback
      if (navigator.canPop()) {
        navigator.pop();
      }
    } catch (e) {
      debugPrint('Error changing language: $e');
    }
  }
}
