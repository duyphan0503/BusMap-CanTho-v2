import 'dart:io';

import 'package:busmapcantho/core/services/notification_snackbar_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../gen/assets.gen.dart';
import '../../cubits/account/account_cubit.dart';
import '../../routes/app_routes.dart';
import '../../widgets/language_selector_widget.dart';
import '../../widgets/change_password_dialog.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  AccountScreenState createState() => AccountScreenState();
}

class AccountScreenState extends State<AccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  File? _imageFile;
  bool _notificationsEnabled = true;
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    context.read<AccountCubit>().getCurrentUser();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      });
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        if (!mounted) return;
        context.read<AccountCubit>().updateProfileImage(_imageFile!);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('errorPickingImage'.tr());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountCubit, AccountState>(
      listener: (context, state) {
        if (state is AccountUpdateSuccess) {
          context.showSuccessSnackBar(state.message);
        } else if (state is AccountError) {
          context.showErrorSnackBar(state.message);
        } else if (state is AccountSignedOut) {
          context.go(AppRoutes.signIn);
        }
      },
      builder: (context, state) {
        final isLoading = state is AccountLoading;
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(context),
          body: RefreshIndicator(
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollUpdateNotification) {
                  _scrollOffset.value = scrollNotification.metrics.pixels;
                }
                return true;
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        _buildBackground(),
                        _buildProfileSection(context, isLoading, state),
                        if (isLoading)
                          const Positioned.fill(
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryMedium,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(height: 32),
                          _buildSecuritySection(context, isLoading, state),
                          const Divider(height: 32),
                          _buildPreferencesSection(context, isLoading),
                          const Divider(height: 32),
                          _buildSupportSection(context),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onRefresh: () async {
              context.read<AccountCubit>().getCurrentUser();
              await _loadPreferences();
            },
          ),
        );
      },
    );
  }

  Widget _buildBackground() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.images.canthoBackground.path),
          fit: BoxFit.fill,
          colorFilter: ColorFilter.mode(
            Colors.black.withAlpha(50),
            BlendMode.darken,
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ValueListenableBuilder<double>(
        valueListenable: _scrollOffset,
        builder: (context, offset, child) {
          return AppBar(
            title: Text(
              'account'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppColors.textOnPrimary),
            ),
            iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
            actions: const [LanguageSelectorWidget()],
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace:
                offset > 0
                    ? Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                    )
                    : null,
          );
        },
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    bool isLoading,
    AccountState state,
  ) {
    String? displayName;
    String? email;
    String? avatarUrl;

    if (state is AccountLoaded || state is AccountUpdateSuccess) {
      final user =
          (state is AccountLoaded)
              ? state.user
              : (state as AccountUpdateSuccess).user;
      displayName = user.userMetadata?['full_name'] as String?;
      email = user.email;
      avatarUrl = user.userMetadata?['avatar_url'] as String?;
      _nameController.text = displayName ?? '';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 80),
          _buildProfileImage(context, isLoading, avatarUrl),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'displayName'.tr(),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: AppColors.cardBackground,
            ),
            style: Theme.of(context).textTheme.bodyLarge,
            enabled: !isLoading,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.email, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              if (email != null && email.isNotEmpty)
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                isLoading
                    ? null
                    : () => context.read<AccountCubit>().updateDisplayName(
                      _nameController.text,
                    ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryMedium,
              foregroundColor: AppColors.textOnPrimary,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Text('updateProfile'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(
    BuildContext context,
    bool isLoading,
    String? avatarUrl,
  ) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryLight, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(50),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.backgroundLight,
              backgroundImage: _getProfileImage(avatarUrl),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.camera_alt, size: 28),
              color: AppColors.textOnPrimary,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primaryMedium,
                padding: const EdgeInsets.all(8),
              ),
              onPressed: isLoading ? null : _pickImage,
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? _getProfileImage(String? avatarUrl) {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CachedNetworkImageProvider(avatarUrl);
    }
    return AssetImage(Assets.images.defaultAvatar.path);
  }

  Widget _buildSecuritySection(
    BuildContext context,
    bool isLoading,
    AccountState state,
  ) {
    final email = (state is AccountLoaded) ? state.user.email : null;

    if (email == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('security'.tr(), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ListTile(
          title: Text('changePassword'.tr()),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap:
              isLoading
                  ? null
                  : () => showDialog(
                    context: context,
                    builder:
                        (context) => ChangePasswordDialog(
                          onSubmit: (oldPassword, newPassword) {
                            context.read<AccountCubit>().changePassword(
                              oldPassword: oldPassword,
                              newPassword: newPassword,
                            );
                          },
                        ),
                  ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(BuildContext context, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('preferences'.tr(), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text(
            'enableNotifications'.tr(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          activeColor: AppColors.primaryMedium,
          value: _notificationsEnabled,
          onChanged:
              isLoading
                  ? null
                  : (value) {
                    setState(() => _notificationsEnabled = value);
                    context.read<AccountCubit>().toggleNotifications(value);
                  },
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('support'.tr(), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        _buildSupportTile(
          icon: Icons.help_outline,
          title: 'helpAndSupport'.tr(),
          onTap: () => _navigateToHelpScreen(context),
        ),
        _buildSupportTile(
          icon: Icons.info_outline,
          title: 'aboutApp'.tr(),
          onTap: () => _showAboutApp(context),
        ),
        _buildSupportTile(
          icon: Icons.exit_to_app,
          title: 'signOut'.tr(),
          color: AppColors.error,
          onTap: () => context.read<AccountCubit>().signOut(),
        ),
      ],
    );
  }

  Widget _buildSupportTile({
    required IconData icon,
    required String title,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textPrimary),
      title: Text(
        title,
        style: TextStyle(color: color ?? AppColors.textPrimary),
      ),
      onTap: onTap,
    );
  }

  void _navigateToHelpScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => Scaffold(
              appBar: AppBar(
                title: Text('helpAndSupport'.tr()),
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                ),
              ),
              body: const _HelpSupportContent(),
            ),
      ),
    );
  }

  void _showAboutApp(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'BusMap Cần Thơ',
      applicationVersion: '1.0.0',
      applicationIcon: Image.asset(
        'assets/images/app_icon.png',
        width: 48,
        height: 48,
      ),
      children: [
        Text(
          'aboutAppDescription'.tr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _HelpSupportContent extends StatelessWidget {
  const _HelpSupportContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('faqTitle'.tr(), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ..._buildFAQItems(context),
        const SizedBox(height: 24),
        Text('contactUs'.tr(), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        _buildContactInfo(Icons.email, 'support@busmap.com'),
        _buildContactInfo(Icons.phone, '+84 123 456 789'),
      ],
    );
  }

  List<Widget> _buildFAQItems(BuildContext context) {
    return [
      _buildFAQItem(
        context: context,
        question: 'faqItem1'.tr(),
        answer: 'faqAnswer1'.tr(),
      ),
      _buildFAQItem(
        context: context,
        question: 'faqItem2'.tr(),
        answer: 'faqAnswer2'.tr(),
      ),
    ];
  }

  Widget _buildFAQItem({
    required BuildContext context,
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(question),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(answer, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildContactInfo(IconData icon, String info) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryMedium),
      title: Text(info),
    );
  }
}
