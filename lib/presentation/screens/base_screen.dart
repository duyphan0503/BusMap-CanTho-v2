import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../providers/localization_provider.dart';

abstract class BaseScreen<T extends StatefulWidget> extends State<T> {

  Widget buildLanguageButton() {
    return IconButton(
      icon: const Icon(Icons.language),
      onPressed: () {
        Provider.of<LocalizationProvider>(context, listen: false).toggleLocale(context);
      },
      tooltip: 'switchLanguage'.tr(),
    );
  }
}