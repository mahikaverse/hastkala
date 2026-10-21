import 'package:flutter/material.dart';

import '../localization/language_provider.dart';

Future<bool> showWizardExitDialog(BuildContext context) async {
  final lang = LanguageProvider.of(context);
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Text(lang.t('exitWizardTitle')),
      content: Text(lang.t('exitWizardBody')),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(lang.t('continueEditing')),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(lang.t('saveAndExit')),
        ),
      ],
    ),
  );
  return result ?? false;
}