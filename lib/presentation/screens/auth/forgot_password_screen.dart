import 'dart:async'; // Import Timer

import 'package:busmapcantho/core/services/notification_snackbar_service.dart';
import 'package:busmapcantho/core/utils/validators.dart';
import 'package:busmapcantho/presentation/cubits/password/password_cubit.dart';
import 'package:busmapcantho/presentation/routes/app_routes.dart';
import 'package:busmapcantho/presentation/widgets/custom_app_bar.dart';
import 'package:busmapcantho/presentation/widgets/otp_input_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String email;

  const ForgotPasswordScreen({super.key, required this.email});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  String? _otpValue;
  bool _obscureNewPassword = true;

  Timer? _otpResendTimer;
  int _otpResendCountdownSeconds = 60;
  bool _canResendPasswordOtp = false;

  @override
  void initState() {
    super.initState();
    if (widget.email.isNotEmpty) {
      _emailController.text = widget.email;
    }
    // Timer will be started when OTP screen is shown
  }

  void _startResendPasswordOtpTimer() {
    if (!mounted) return;
    setState(() {
      _canResendPasswordOtp = false;
      _otpResendCountdownSeconds = 60;
    });
    _otpResendTimer?.cancel();
    _otpResendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_otpResendCountdownSeconds > 0) {
            _otpResendCountdownSeconds--;
          } else {
            _otpResendTimer?.cancel();
            _canResendPasswordOtp = true;
          }
        });
      } else {
        _otpResendTimer?.cancel();
      }
    });
  }

  void _handleBackButton(PasswordState currentState) {
    if (currentState is PasswordOtpInputState) {
      context.read<PasswordCubit>().goBackToEmailInput();
    } else if (currentState is PasswordEmailInputState) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        context.go(AppRoutes.signIn);
      }
    }
    // No back button for NewPasswordInputState as per original logic
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<PasswordCubit, PasswordState>(
      listener: (context, state) {
        if (state is PasswordRequestOtpSuccess) {
          context.showSuccessSnackBar('otpSentSuccess'.tr());
          _startResendPasswordOtpTimer(); // Start timer when OTP is sent
        } else if (state is PasswordResetSuccess) {
          context.showSuccessSnackBar('resetPasswordSuccess'.tr());
          context.go(AppRoutes.signIn);
        } else if (state is PasswordError) {
          context.showErrorSnackBar(state.message);
        } else if (state is PasswordOtpResent) {
          context.showSuccessSnackBar('otpResentSuccessfully'.tr());
          _startResendPasswordOtpTimer(); // Restart timer
        } else if (state is PasswordOtpResendError) {
          context.showErrorSnackBar(state.message);
          if (mounted && _otpResendCountdownSeconds == 0) {
            setState(() {
              _canResendPasswordOtp = true; // Allow retry if timer finished
            });
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is PasswordLoading;

        return Scaffold(
          appBar: CustomAppBar(
            title: _getAppBarTitle(state),
            leading:
                (state is! PasswordNewPasswordInputState) &&
                        (state is! PasswordResetSuccess)
                    ? BackButton(
                      onPressed: () => _handleBackButton(state),
                      color: theme.colorScheme.onPrimary,
                    )
                    : null,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: _buildBody(context, state, isLoading, theme, colorScheme),
          ),
        );
      },
    );
  }

  String _getAppBarTitle(PasswordState state) {
    if (state is PasswordEmailInputState) {
      return 'forgotPassword'.tr();
    } else if (state is PasswordOtpInputState ||
        state is PasswordRequestOtpSuccess) {
      return 'enterOtp'.tr();
    } else if (state is PasswordNewPasswordInputState) {
      return 'resetPassword'.tr();
    }
    return 'forgotPassword'.tr();
  }

  Widget _buildBody(
    BuildContext context,
    PasswordState state,
    bool isLoading,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (state is PasswordEmailInputState) {
      return _buildEmailStep(context, isLoading, theme, colorScheme);
    } else if (state is PasswordOtpInputState) {
      return _buildOtpStep(context, isLoading, state.email, theme, colorScheme);
    } else if (state is PasswordNewPasswordInputState) {
      return _buildNewPasswordStep(
        context,
        isLoading,
        state.email,
        state.otpCode,
        theme,
        colorScheme,
      );
    } else if (state is PasswordLoading &&
        context.read<PasswordCubit>().state is PasswordInitial) {
      return _buildEmailStep(context, true, theme, colorScheme);
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEmailStep(
    BuildContext context,
    bool isLoading,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Form(
      key: _emailFormKey,
      child: ListView(
        shrinkWrap: true,
        children: [
          Text('enterEmailForReset'.tr(), style: theme.textTheme.titleMedium),
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'email'.tr(),
              prefixIcon: Icon(Icons.email, color: colorScheme.primary),
            ),
            validator: validateEmail,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ElevatedButton(
              onPressed: () {
                if (_emailFormKey.currentState?.validate() ?? false) {
                  context.read<PasswordCubit>().requestPasswordResetOtp(
                    _emailController.text.trim(),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text(
                'sendResetCode'.tr(),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOtpStep(
    BuildContext context,
    bool isLoading,
    String email,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (_emailController.text.isEmpty && email.isNotEmpty) {
      _emailController.text = email;
    }
    // Accessing cubit's state directly for isLoading for resend button
    final passwordCubitState = context.watch<PasswordCubit>().state;
    final isResendingOtp = passwordCubitState is PasswordOtpResending;

    return ListView(
      shrinkWrap: true,
      children: [
        Text(
          tr('otpSentTo', args: [email]),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        OtpInputWidget(
          length: 6,
          boxSize: 40,
          onCompleted: (otp) {
            setState(() {
              _otpValue = otp;
            });
          },
        ),
        const SizedBox(height: 24),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else
          ElevatedButton(
            onPressed: () {
              if ((_otpValue?.length ?? 0) == 6) {
                context.read<PasswordCubit>().proceedToNewPasswordStep(
                  email,
                  _otpValue!,
                );
              } else {
                context.showErrorSnackBar('otpLengthError'.tr());
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: Text(
              'continue'.tr(),
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        const SizedBox(height: 16),
        TextButton(
          onPressed:
              _canResendPasswordOtp && !isResendingOtp
                  ? () {
                    context.read<PasswordCubit>().resendPasswordResetOtp(email);
                  }
                  : null,
          child:
              isResendingOtp
                  ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.primaryColor,
                      ),
                    ),
                  )
                  : Text(
                    _canResendPasswordOtp
                        ? 'resendOtp'.tr()
                        : tr(
                          'resendOtpIn',
                          args: [_otpResendCountdownSeconds.toString()],
                        ),
                    style: TextStyle(
                      color:
                          _canResendPasswordOtp && !isResendingOtp
                              ? theme.primaryColor
                              : theme.disabledColor,
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildNewPasswordStep(
    BuildContext context,
    bool isLoading,
    String email,
    String otpCode,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Form(
      key: _passwordFormKey,
      child: ListView(
        shrinkWrap: true,
        children: [
          Text('setNewPassword'.tr(), style: theme.textTheme.titleMedium),
          const SizedBox(height: 24),
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            decoration: InputDecoration(
              labelText: 'newPassword'.tr(),
              prefixIcon: Icon(Icons.lock, color: colorScheme.primary),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                  color: colorScheme.primary,
                ),
                onPressed: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
              ),
            ),
            validator: validatePassword,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ElevatedButton(
              onPressed: () {
                if (_passwordFormKey.currentState?.validate() ?? false) {
                  context.read<PasswordCubit>().resetPasswordWithOtp(
                    email: email,
                    otpCode: otpCode,
                    newPassword: _newPasswordController.text,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text(
                'resetPassword'.tr(),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _otpResendTimer?.cancel(); // Dispose the timer
    super.dispose();
  }
}
