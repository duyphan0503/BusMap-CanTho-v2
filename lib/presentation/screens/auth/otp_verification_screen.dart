import 'dart:async';

import 'package:busmapcantho/core/services/notification_snackbar_service.dart';
import 'package:busmapcantho/presentation/routes/app_routes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../cubits/otp/otp_cubit.dart';
import '../../cubits/otp/otp_state.dart';
import '../../widgets/otp_input_widget.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  Timer? _timer;
  int _countdownSeconds = 60;
  bool _canResendOtp = false;

  @override
  void initState() {
    super.initState();
    _startResendOtpTimer();
  }

  void _startResendOtpTimer() {
    _canResendOtp = false;
    _countdownSeconds = 60;
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          if (_countdownSeconds > 0) {
            _countdownSeconds--;
          } else {
            _timer?.cancel();
            _canResendOtp = true;
          }
        });
      } else {
        _timer?.cancel(); // Cancel timer if widget is disposed
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<OtpCubit, OtpState>(
      listener: (context, state) {
        if (state is OtpVerified) {
          context.showSuccessSnackBar('emailVerifiedSuccessfully'.tr());
          context.go(AppRoutes.home);
        } else if (state is OtpError) {
          context.showErrorSnackBar(state.message);
        } else if (state is OtpResent) {
          context.showSuccessSnackBar('otpResentSuccessfully'.tr());
          // Timer is already started by the resend button's onPressed logic
        } else if (state is OtpResendError) {
          context.showErrorSnackBar(state.message);
          // Allow user to try again if countdown finished
          if (_countdownSeconds == 0 && mounted) {
            setState(() {
              _canResendOtp = true;
            });
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  'emailVerify'.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                automaticallyImplyLeading: true,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                Text(
                  tr('enterVerificationCodeSentTo', args: [widget.email]),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                OtpInputWidget(
                  onCompleted: (otp) {
                    context.read<OtpCubit>().verifyEmailOtp(
                      email: widget.email,
                      otp: otp,
                    );
                  },
                  length: 6,
                  boxSize: 40,
                  spacing: 8,
                ),
                const SizedBox(height: 24),
                if (state is OtpLoading) const CircularProgressIndicator(),
                const SizedBox(height: 16),
                TextButton(
                  onPressed:
                      _canResendOtp && state is! OtpResending
                          ? () {
                            context.read<OtpCubit>().resendEmailOtp(
                              email: widget.email,
                            );
                            _startResendOtpTimer(); // Restart timer on resend
                          }
                          : null,
                  child:
                      state is OtpResending
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
                            _canResendOtp
                                ? 'resendOtp'.tr()
                                : tr(
                                  'resendOtpIn',
                                  args: [_countdownSeconds.toString()],
                                ),
                          ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
