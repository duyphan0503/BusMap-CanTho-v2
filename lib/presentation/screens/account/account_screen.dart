import 'dart:io';

import 'package:busmapcantho/presentation/routes/app_routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../cubits/account/account_cubit.dart';
import '../../widgets/language_selector_widget.dart';

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('errorPickingImage'.tr())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountCubit, AccountState>(
      listener: _handleAccountStateChanges,
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(context),
          body: _buildBody(context, state),
        );
      },
    );
  }

  void _handleAccountStateChanges(BuildContext context, AccountState state) {
    if (state is AccountUpdateSuccess) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message)));
    } else if (state is AccountError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message)));
    } else if (state is AccountSignedOut) {
      context.go(AppRoutes.signIn);
    }
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('account'.tr()),
      actions: [const LanguageSelectorWidget()],
    );
  }

  Widget _buildBody(BuildContext context, AccountState state) {
    final isLoading = state is AccountLoading;

    // User information comes from state
    String? displayName;
    String? email;
    String? avatarUrl;
    String? userId;

    if (state is AccountLoaded || state is AccountUpdateSuccess) {
      final user =
          (state is AccountLoaded)
              ? state.user
              : (state as AccountUpdateSuccess).user;
      displayName = user.fullName;
      email = user.email;
      avatarUrl = user.avatarUrl;
      userId = user.id;
      _nameController.text = displayName ?? '';
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            context.read<AccountCubit>().getCurrentUser();
            await _loadPreferences();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileImage(context, isLoading, avatarUrl),
                const SizedBox(height: 20),
                _buildProfileSection(context, isLoading, email, userId),
                const Divider(height: 32),
                _buildPasswordSection(context, isLoading, email),
                const Divider(height: 32),
                _buildPreferencesSection(context, isLoading),
                const Divider(height: 32),
                _buildSupportSection(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        if (isLoading)
          const Positioned.fill(
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
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
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            backgroundImage: _getProfileImage(avatarUrl),
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: isLoading ? null : _pickImage,
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
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
    } else {
      return const AssetImage('assets/images/default_avatar.png');
    }
  }

  Widget _buildProfileSection(
    BuildContext context,
    bool isLoading,
    String? email,
    String? userId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'personalInfo'.tr(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'displayName'.tr(),
            border: const OutlineInputBorder(),
          ),
          enabled: !isLoading,
        ),
        const SizedBox(height: 16),
        Text(
          '${'email'.tr()}: ${email ?? 'notAvailable'.tr()}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        if (userId != null)
          Text(
            'ID: $userId',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                isLoading
                    ? null
                    : () => context.read<AccountCubit>().updateDisplayName(
                      _nameController.text,
                    ),
            child: Text('updateProfile'.tr()),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordSection(
    BuildContext context,
    bool isLoading,
    String? email,
  ) {
    // Chỉ hiển thị phần đổi mật khẩu nếu user đăng nhập bằng email
    if (email == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('security'.tr(), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'newPassword'.tr(),
            border: const OutlineInputBorder(),
          ),
          obscureText: true,
          enabled: !isLoading,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                (isLoading || _passwordController.text.isEmpty)
                    ? null
                    : () {
                      context.read<AccountCubit>().changePassword(
                        _passwordController.text,
                      );
                      _passwordController.clear();
                    },
            child: Text('changePassword'.tr()),
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
          title: Text('enableNotifications'.tr()),
          value: _notificationsEnabled,
          onChanged:
              isLoading
                  ? null
                  : (value) {
                    setState(() => _notificationsEnabled = value);
                    context.read<AccountCubit>().toggleNotifications(value);
                  },
        ),
        const _PreferenceItem(
          title: 'savedRoutes',
          featureKey: 'savedRoutesFeatureComingSoon',
        ),
        const _PreferenceItem(
          title: 'tripHistory',
          featureKey: 'tripHistoryFeatureComingSoon',
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
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: Text('helpAndSupport'.tr()),
          onTap: () => _navigateToHelpScreen(context),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text('aboutApp'.tr()),
          onTap: () => _showAboutApp(context),
        ),
        ListTile(
          leading: const Icon(Icons.exit_to_app, color: Colors.red),
          title: Text(
            'signOut'.tr(),
            style: const TextStyle(color: Colors.red),
          ),
          onTap: () => context.read<AccountCubit>().signOut(),
        ),
      ],
    );
  }

  void _navigateToHelpScreen(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => _HelpSupportScreen()));
  }

  void _showAboutApp(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'BusMap Cần Thơ',
      applicationVersion: '1.0.0',
      applicationIcon: Image.asset(
        'assets/translations/app_icon.png',
        width: 48,
        height: 48,
        errorBuilder: (ctx, obj, trace) => const Icon(Icons.directions_bus),
      ),
      children: [const SizedBox(height: 16), Text('aboutAppDescription'.tr())],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _PreferenceItem extends StatelessWidget {
  final String title;
  final String featureKey;

  const _PreferenceItem({required this.title, required this.featureKey});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title.tr()),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) => Scaffold(
                  appBar: AppBar(title: Text(title.tr())),
                  body: Center(child: Text(featureKey.tr())),
                ),
          ),
        );
      },
    );
  }
}

class _HelpSupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('helpAndSupport'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('faqTitle'.tr(), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ExpansionTile(
            title: Text('faqItem1'.tr()),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('faqAnswer1'.tr()),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('faqItem2'.tr()),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('faqAnswer2'.tr()),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('contactUs'.tr(), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          const ListTile(
            leading: Icon(Icons.email),
            title: Text('support@busmap.com'),
          ),
          const ListTile(
            leading: Icon(Icons.phone),
            title: Text('+84 123 456 789'),
          ),
        ],
      ),
    );
  }
}
