import 'package:busmapcantho/presentation/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OtpCubit, OtpState>(
      listener: (context, state) {
        if (state is OtpVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email verified successfully!')),
          );
          context.go(AppRoutes.home);
        } else if (state is OtpError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Email Verification')),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                Text(
                  "Enter the verification code sent to ${widget.email}",
                  textAlign: TextAlign.center,
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
                  boxSize: 20,
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
