import 'package:busmapcantho/core/utils/validators.dart';
import 'package:busmapcantho/presentation/cubits/auth/auth_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/notification_snackbar_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: _buildAppBar(theme),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildNameField(theme),
                const SizedBox(height: 16),
                _buildEmailField(theme),
                const SizedBox(height: 16),
                _buildPasswordField(theme, colorScheme),
                const SizedBox(height: 16),
                _buildConfirmPasswordField(theme, colorScheme),
                const SizedBox(height: 24),
                _buildSignUpButton(theme, colorScheme),
                const SizedBox(height: 16),
                _buildSignInRow(theme, colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return PreferredSize(
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
            'signUp'.tr(),
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: true,
        ),
      ),
    );
  }

  Widget _buildNameField(ThemeData theme) {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'fullName'.tr(),
        prefixIcon: const Icon(Icons.person),
      ),
      validator: validateFullName,
      style: theme.textTheme.bodyLarge,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildEmailField(ThemeData theme) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'email'.tr(),
        prefixIcon: const Icon(Icons.email),
      ),
      validator: validateEmail,
      style: theme.textTheme.bodyLarge,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildPasswordField(ThemeData theme, ColorScheme colorScheme) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'password'.tr(),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: colorScheme.primary,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: validatePassword,
      style: theme.textTheme.bodyLarge,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildConfirmPasswordField(ThemeData theme, ColorScheme colorScheme) {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: 'confirmPassword'.tr(),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            color: colorScheme.primary,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
      ),
      validator:
          (value) => validateConfirmPassword(value, _passwordController.text),
      style: theme.textTheme.bodyLarge,
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildSignUpButton(ThemeData theme, ColorScheme colorScheme) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthVerifying) {
          context.showSuccessSnackBar('verificationEmailSentMessage'.tr());
          context.go(AppRoutes.verify, extra: {"email": _emailController.text});
        } else if (state is AuthError) {
          context.showErrorSnackBar(state.error);
        }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              context.read<AuthCubit>().signUp(
                _emailController.text.trim(),
                _passwordController.text.trim(),
                _nameController.text.trim(),
              );
            }
          },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            textStyle: theme.textTheme.labelLarge,
          ),
          child: Text('signUp'.tr(), style: theme.textTheme.labelLarge),
        );
      },
    );
  }

  Widget _buildSignInRow(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('alreadyHaveAnAccount'.tr(), style: theme.textTheme.bodyMedium),
        TextButton(
          onPressed: () => context.go(AppRoutes.signIn),
          child: Text(
            'signIn'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
