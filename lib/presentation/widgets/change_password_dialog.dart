import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/theme/app_colors.dart';

class ChangePasswordDialog extends StatefulWidget {
  final void Function(String oldPassword, String newPassword) onSubmit;

  const ChangePasswordDialog({required this.onSubmit, super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('changePassword'.tr()),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'oldPassword'.tr()),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'requiredField'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'newPassword'.tr()),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'requiredField'.tr();
                }
                if (value.length < 6) {
                  return 'passwordTooShort'.tr();
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        ElevatedButton(
          onPressed:
              _isSubmitting
                  ? null
                  : () {
                      if (_formKey.currentState?.validate() ?? false) {
                        setState(() => _isSubmitting = true);
                        widget.onSubmit(
                          _oldPasswordController.text,
                          _newPasswordController.text,
                        );
                        if (mounted) Navigator.pop(context);
                      }
                    },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryMedium,
            foregroundColor: AppColors.textOnPrimary,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  'changePassword'.tr(),
                  style: const TextStyle(color: AppColors.textOnPrimary),
                ),
        ),
      ],
    );
  }
}
