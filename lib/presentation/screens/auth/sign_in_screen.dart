import 'package:busmapcantho/core/utils/validators.dart';
import 'package:busmapcantho/presentation/widgets/language_selector_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../gen/assets.gen.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../routes/app_routes.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.home);
          _showSuccessMessage(context, 'loginSuccess'.tr());
        } else if (state is AuthError) {
          _showErrorMessage(context, state.error);
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: _buildLoginForm(theme, colorScheme),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSize _buildAppBar() {
    final theme = Theme.of(context);
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'signIn'.tr(),
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: const [LanguageSelectorWidget()],
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
      ),
    );
  }

  Widget _buildLoginForm(ThemeData theme, ColorScheme colorScheme) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 100,
            width: 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primary.withAlpha((0.08 * 255).toInt()),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Image.asset(Assets.images.logo.path, fit: BoxFit.cover),
          ),
          const SizedBox(height: 40),

          // Email field
          TextFormField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            decoration: InputDecoration(
              labelText: 'email'.tr(),
              hintText: 'emailHint'.tr(),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: colorScheme.primary,
              ),
              // Sử dụng style từ theme
            ),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_passwordFocusNode);
            },
            validator: validateEmail,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),

          // Password field
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            decoration: InputDecoration(
              labelText: 'password'.tr(),
              hintText: 'passwordHint'.tr(),
              prefixIcon: Icon(Icons.lock_outline, color: colorScheme.primary),
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
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _attemptLogin(),
            validator: validatePassword,
            style: theme.textTheme.bodyLarge,
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                context.go(
                  AppRoutes.forgotPassword,
                  extra: {"email": _emailController.text},
                );
              },
              child: Text(
                'forgotPassword'.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return FilledButton(
                onPressed: isLoading ? null : _attemptLogin,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  textStyle: theme.textTheme.labelLarge,
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Text(
                          'signIn'.tr(),
                          style: theme.textTheme.labelLarge,
                        ),
              );
            },
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('noAccountQuestion'.tr(), style: theme.textTheme.bodyMedium),
              TextButton(
                onPressed: () => context.push(AppRoutes.signUp),
                child: Text(
                  'register'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 32, color: theme.dividerColor),

          // Đăng nhập bằng Google
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return OutlinedButton.icon(
                icon: Icon(
                  Icons.g_mobiledata,
                  size: 24,
                  color: colorScheme.primary,
                ),
                label: Text(
                  'loginWithGoogle'.tr(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: colorScheme.primary),
                  foregroundColor: colorScheme.primary,
                ),
                onPressed:
                    state is AuthLoading
                        ? null
                        : () => context.read<AuthCubit>().signInWithGoogle(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _attemptLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signIn(
        _emailController.text,
        _passwordController.text,
      );
    }
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: AppColors.textOnPrimary),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${'error'.tr()}: $message',
          style: TextStyle(color: AppColors.textOnPrimary),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
