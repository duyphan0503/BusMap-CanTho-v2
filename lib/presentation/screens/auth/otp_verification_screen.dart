import 'package:busmapcantho/core/services/notification_snackbar_service.dart';
import 'package:busmapcantho/presentation/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../cubits/otp/otp_cubit.dart';
import '../../cubits/otp/otp_state.dart';
import '../../widgets/otp_input_widget.dart';
import '../../../core/theme/app_colors.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
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
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
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
              ],
            ),
          ),
        );
      },
    );
  }
}
