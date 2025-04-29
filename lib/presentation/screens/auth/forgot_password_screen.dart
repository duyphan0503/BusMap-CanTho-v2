import 'package:busmapcantho/core/utils/validators.dart';
import 'package:busmapcantho/presentation/cubits/password/password_cubit.dart';
import 'package:busmapcantho/presentation/routes/app_routes.dart';
import 'package:busmapcantho/presentation/widgets/otp_input_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

enum PasswordResetStep { emailInput, otpInput, newPasswordInput }

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

  // Track current step in the password reset flow
  PasswordResetStep _currentStep = PasswordResetStep.emailInput;

  @override
  void initState() {
    super.initState();
    // Pre-fill email if provided
    if (widget.email.isNotEmpty) {
      _emailController.text = widget.email;
    }
  }

  void _handleBackButton() {
    if (_currentStep == PasswordResetStep.otpInput) {
      setState(() {
        _currentStep = PasswordResetStep.emailInput;
      });
    } else if (_currentStep == PasswordResetStep.emailInput) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        context.go(AppRoutes.signIn);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        leading:
            _currentStep != PasswordResetStep.newPasswordInput
                ? BackButton(onPressed: _handleBackButton)
                : null,
      ),
      body: BlocConsumer<PasswordCubit, PasswordState>(
        listener: (context, state) {
          if (state is PasswordRequestOtpSuccess) {
            // Move to OTP step when OTP request is successful
            setState(() {
              _currentStep = PasswordResetStep.otpInput;
            });
            _showMessage('otpSentSuccess'.tr());
          } else if (state is PasswordResetSuccess) {
            _showMessage('resetPasswordSuccess'.tr());
            context.go(AppRoutes.signIn);
          } else if (state is PasswordError) {
            _showMessage(state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is PasswordLoading;

          return Padding(
            padding: const EdgeInsets.all(24),
            child:
                _currentStep == PasswordResetStep.emailInput
                    ? _buildEmailStep(isLoading)
                    : _currentStep == PasswordResetStep.otpInput
                    ? _buildOtpStep(isLoading)
                    : _buildNewPasswordStep(isLoading),
          );
        },
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentStep) {
      case PasswordResetStep.emailInput:
        return 'forgotPassword'.tr();
      case PasswordResetStep.otpInput:
        return 'enterOtp'.tr();
      case PasswordResetStep.newPasswordInput:
        return 'resetPassword'.tr();
    }
  }

  Widget _buildEmailStep(bool isLoading) {
    return Form(
      key: _emailFormKey,
      child: ListView(
        shrinkWrap: true,
        children: [
          Text('enterEmailForReset'.tr(), style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'email'.tr(),
              prefixIcon: const Icon(Icons.email),
              border: const OutlineInputBorder(),
            ),
            validator: validateEmail,
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
              ),
              child: Text('sendResetCode'.tr()),
            ),
        ],
      ),
    );
  }

  Widget _buildOtpStep(bool isLoading) {
    return ListView(
      shrinkWrap: true,
      children: [
        Text(
          '${'otpSentTo'.tr()} ${_emailController.text}',
          style: const TextStyle(fontSize: 16),
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
                setState(() {
                  _currentStep = PasswordResetStep.newPasswordInput;
                });
              } else {
                _showMessage('otpLengthError'.tr());
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text('continue'.tr()),
          ),
      ],
    );
  }

  Widget _buildNewPasswordStep(bool isLoading) {
    return Form(
      key: _passwordFormKey,
      child: ListView(
        shrinkWrap: true,
        children: [
          Text('setNewPassword'.tr(), style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            decoration: InputDecoration(
              labelText: 'newPassword'.tr(),
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
              ),
            ),
            validator: validatePassword,
          ),
          const SizedBox(height: 24),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ElevatedButton(
              onPressed: () {
                if (_passwordFormKey.currentState?.validate() ?? false) {
                  context.read<PasswordCubit>().resetPasswordWithOtp(
                    email: _emailController.text.trim(),
                    otpCode: _otpValue!,
                    newPassword: _newPasswordController.text,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('resetPassword'.tr()),
            ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }
}
